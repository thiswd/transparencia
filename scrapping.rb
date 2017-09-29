require 'open-uri'
require 'nokogiri'
require 'json'
require 'pry-byebug'

servidores = []
servidores_sem_salario = []
filepath = 'data/servidores.json'
filepath2 = 'data/servidores_sem_salario.json'

(1536..3783).each do |page|

  print page

  url = "http://www.portaltransparencia.gov.br/servidores/OrgaoExercicio-ListaServidores.asp?CodOrg=25000&Pagina=#{page}"
  raw_html = open(url).read
  html = Nokogiri::HTML(raw_html)

  html.search("#listagem table td:nth-child(2) a").each do |servidor|
    name = servidor.text.strip
    path = servidor.attr("href")
    url = "http://www.portaltransparencia.gov.br/servidores/#{path}"

    raw_html = open(url).read
    html = Nokogiri::HTML(raw_html)


    cargo = html.search("#listagemConvenios tr td:nth-child(2)")[28]

    if cargo && !cargo.text.include?("*")
      cargo = cargo.text.strip
    else
      cargo = html.search("#listagemConvenios tr td:nth-child(2)")[1].text.strip

      if cargo == ""
        descricao = html.search("#listagemConvenios tr td:nth-child(2)")[2]
        atividade = html.search("#listagemConvenios tr td:nth-child(2)")[3]
        cargo = "#{descricao.text.strip} - #{atividade.text.strip}"
      end
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
      servidores << { name: name, job: cargo, salary_b: salario_b.text, salary_l: salario_l.text  }
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
