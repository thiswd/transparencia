require "open-uri"
require "nokogiri"
require "json"

pages_amount = ARGV[0]

servers = []
wages_not_found = []
servers_path = "data/servers.json"
without_wages_path = "data/wages_not_found.json"
base_url = "https://www.portaltransparencia.gov.br"
servers_route = "/servidores/"

(1..pages_amount).each do |page_number|

  print page_number

  url = "#{base_url}#{servers_route}OrgaoExercicio-ListaServidores.asp?CodOrg=17000&Pagina=#{page_number}"
  raw_html = open(url).read
  html = Nokogiri::HTML(raw_html)

  html.search("#listagem table td:nth-child(2) a").each do |server|
    name = server.text.strip
    path = server.attr("href")
    server_url = base_url + servers_route + path

    raw_html = open(server_url).read
    html = Nokogiri::HTML(raw_html)

    info_id = "#listagemConvenios"

    position = html.search("#{info_id} tr td:nth-child(2)")[28]

    if position && !position.text.include?("*")
      position = position.text.strip
    else
      position = html.search("#{info_id} tr td:nth-child(2)")[1].text.strip

      if position == ""
        description = html.search("#{info_id} tr td:nth-child(2)")[2]
        activity = html.search("#{info_id} tr td:nth-child(2)")[3]
        position = "#{description.text.strip} - #{activity.text.strip}"
      end
    end

    go_to_remuneration = html.search("#resumo a")[0]
    path = go_to_remuneration.attr("href")

    url = base_url + path
    raw_html = open(url).read
    html = Nokogiri::HTML(raw_html)

    gross_salary_element = html.search("#{info_id} tbody tr:nth-child(5) .colunaValor")

    net_salary_element = html.search(".remuneracaolinhatotalliquida .colunaValor")[0]

    print "."

    if net_salary_element
      server = {
        name: name,
        job: position,
        gross_salary: gross_salary_element.text,
        net_salary: net_salary_element.text,
        link: server_url
      }

      servers << server
    else
      wages_not_found << { name: name, job: position, link: server_url }
    end
  end

  File.open(servers_path, "wb") do |file|
    file.write(JSON.generate(servers))
  end

  File.open(without_wages_path, "wb") do |file|
    file.write(JSON.generate(wages_not_found))
  end

end
