require 'open-uri'
require 'nokogiri'
require 'json'
require 'pry-byebug'

servidores = []
servidores_sem_salario = []
filepath = 'data/servidores.json'
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

    salario = html.search(".remuneracaolinhatotalliquida .colunaValor")[0]

    print "="

    if salario
      if cargo
        servidores << { name: name, salary: salario.text, job: cargo.text.strip }
      else
        servidores << { name: name, salary: salario.text }
      end
    else
      servidores_sem_salario << name
    end
  end

  File.open(filepath, 'wb') do |file|
    file.write(JSON.generate(servidores))
  end
end

puts
puts "Servidores:"
servidores.each do |servidor|
  puts "#{servidor[:name]} - #{servidor[:salary]} - #{servidor[:job]}"
end

puts
puts "Servidores sem salário:"
servidores_sem_salario.each do |servidor|
  puts servidor
end
