require 'open-uri'
require 'nokogiri'
require 'json'
require 'pry-byebug'

servidores = []
servidores_sem_salario = []
filepath = 'data/servidores.json'
filepath2 = 'data/servidores_sem_salario.json'


(1..261).each do |page|
  url = "http://www.portaltransparencia.gov.br/servidores/OrgaoExercicio-ListaServidores.asp?CodOrg=25201&Pagina=#{page}"
  raw_html = open(url).read
  html = Nokogiri::HTML(raw_html)

  html.search("#listagem table td:nth-child(2) a").each do |servidor|
    name = servidor.text.strip
    path = servidor.attr("href")
    url = "http://www.portaltransparencia.gov.br/servidores/#{path}"

    raw_html = open(url).read
    html = Nokogiri::HTML(raw_html)


    cargo = html.search("#listagemConvenios tr td:nth-child(2)")[28]

    unless cargo
      cargo = html.search("#listagemConvenios tr td:nth-child(2)")[1]
    end

    link_da_remuneracao = html.search("#resumo a")[0]
    path = link_da_remuneracao.attr("href")

    url = "http://www.portaltransparencia.gov.br#{path}"
    raw_html = open(url).read
    html = Nokogiri::HTML(raw_html)

    salario_b = html.search("#listagemConvenios tbody tr:nth-child(5) .colunaValor")

    salario_l = html.search(".remuneracaolinhatotalliquida .colunaValor")[0]

    print "="

    if salario_l
      servidores << { name: name, job: cargo.text.strip, salary_b: salario_b.text, salary_l: salario_l.text  }
    else
      servidores_sem_salario << name
    end
  end

  File.open(filepath, 'wb') do |file|
    file.write(JSON.generate(servidores))
  end

  File.open(filepath2, 'wb') do |file|
    file.write(JSON.generate(servidores_sem_salario))
  end

end
