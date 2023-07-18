require 'open-uri'
require 'nokogiri'
require 'json'

class Scrapper
  attr_reader :servants, :wages_not_found, :pages_amount

  BASE_URL = 'https://www.portaltransparencia.gov.br'.freeze
  SERVANTS_ROUTE = '/servidores/'.freeze
  INFO_ID = '#listagemConvenios'.freeze

  def initialize(pages_amount)
    @pages_amount = pages_amount
    @servants = []
    @wages_not_found = []
  end

  def perform
    (1..pages_amount).each do |page_number|
      print page_number

      page_url = construct_url(page_number)
      html = fetch_html(page_url)

      html.search("#listagem table td:nth-child(2) a").each do |servant|
        process_servant(servant)
      end

      write_to_file('data/servants.json', servants)
      write_to_file('data/wages_not_found.json', wages_not_found)
    end
  end

  private

  def construct_url(page_number)
    "#{BASE_URL}#{SERVANTS_ROUTE}OrgaoExercicio-ListaServidores.asp?CodOrg=17000&Pagina=#{page_number}"
  end

  def fetch_html(url)
    raw_html = open(url).read
    Nokogiri::HTML(raw_html)
  end

  def process_servant(servant)
    name = servant.text.strip
    path = servant.attr("href")
    servant_url = BASE_URL + SERVANTS_ROUTE + path

    html = fetch_html(servant_url)
    position = set_position(html)

    path = html.search("#resumo a")[0].attr("href")

    remuneration_url = BASE_URL + path
    html = fetch_html(remuneration_url)

    gross_salary_element = html.search("#{INFO_ID} tbody tr:nth-child(5) .colunaValor")
    net_salary_element = html.search(".remuneracaolinhatotalliquida .colunaValor")[0]

    if net_salary_element
      servant = {
        name: name,
        job: position,
        gross_salary: gross_salary_element.text,
        net_salary: net_salary_element.text,
        link: servant_url
      }

      servants << servant
    else
      wages_not_found << { name: name, job: position, link: servant_url }
    end

    print "."
  end

  def write_to_file(path, content)
    File.open(path, "wb") do |file|
      file.write(JSON.generate(content))
    end
  end

  def set_position(html)
    position = html.search("#{INFO_ID} tr td:nth-child(2)")[28]

    if position && !position.text.include?("*")
      position = position.text.strip
    else
      position = html.search("#{INFO_ID} tr td:nth-child(2)")[1].text.strip

      if position == ""
        description = html.search("#{INFO_ID} tr td:nth-child(2)")[2]
        activity = html.search("#{INFO_ID} tr td:nth-child(2)")[3]
        position = "#{description.text.strip} - #{activity.text.strip}"
      end
    end

    position
  end
end

pages_amount = ARGV[0]
scrapper = Scrapper.new(pages_amount)
scrapper.perform
