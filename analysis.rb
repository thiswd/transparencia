require 'json'
require 'pry-byebug'

def strFormat(n)
  n.gsub(/[.,]/, '.' => "", "," => ".")
end

def change(b,l)
  total = (l - b)/b * 100
end

total_employees = 0

orgs = %w(agu anac anp anvisa bc cgu cvm ebc embrapa fiocruz funai ibge inss iphan mapa mcid mctic mdic mds me mec mf mi minc mj mma mme mp mre ms mt mte mtur pf pr)

high_wages = []

orgs.each do |org|
  filepath = "data/servidores_#{org}.json"

  serialized_employees = File.read(filepath)

  employees = JSON.parse(serialized_employees, symbolize_names: true)

  total_employees += employees.size
  sum_b = 0
  sum_l = 0
  employee_count = 0
  porcentage_positive = []
  high_wages = []

  employees.each do |employee|

    salary_b = strFormat(employee[:salary_b]).to_f
    salary_l = strFormat(employee[:salary_l]).to_f

    porcentage = change(salary_b,salary_l).round(1)

    # puts "#{porcentage}% - #{employee['name']} - #{employee['job']} - #{salary_b} - #{salary_l}"
    if salary_l > 0
      sum_l += salary_l
    end

    if salary_b > 0
      sum_b += salary_b
      employee_count += 1
    end

    if porcentage > 70 && porcentage < 100000
      porcentage_positive << { name: employee[:name], porcentage: porcentage }
    end

    if salary_l > 39000
      high_wages << employee
    end

  end

  filepath = "data/servidores_sem_salario_#{org}.json"

  serialized_employees = File.read(filepath)

  no_wage_employees = JSON.parse(serialized_employees, symbolize_names: true)

  puts "========================================================="
  puts "#{org.upcase}"
  puts "========================================================="


  no_wage_employees.each do |employee|

    if employee.class == Hash
      print "#{employee[:name]}, "
    else
      print "#{employee}, "
    end

  end
  # puts "========================================================="
  # puts "Empregados sem salário - #{no_wage_employees.count}"
  # puts


  # puts "========================================================="
  # puts "Médias - #{org.upcase}"
  # puts
  # puts "Salário bruto - R$ #{(sum_b/employee_count).round(2)}"
  # puts "Salário líquido - R$ #{(sum_l/employee_count).round(2)}"
  # puts "Empregados com salário - #{employee_count}"
  # puts "Total - #{employees.count}"
  # puts "---------------------------------------------------------"
  # puts "Variação acima de 70% no #{org.upcase}"
  # puts

  # porcentage_positive.each do |employee|
  #   if employee.key?(:link)
  #     puts "#{employee[:name]} - #{employee[:porcentage]}% - #{employee[:link]}"
  #   else
  #     puts "#{employee[:name]} - #{employee[:porcentage]}%"
  #   end
  # end
  # puts "========================================================="
  # puts

  # high_wages.each do |employee|
  #   puts "#{employee[:name]} - #{employee[:job]} - #{employee[:salary_l]}"
  # end


end

  # puts high_wages.size
  # puts
# puts "Total de servidores: #{total_employees}"
