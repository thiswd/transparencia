require 'json'
require 'pry-byebug'

def strFormat(n)
  n.gsub(/[.,]/, '.' => "", "," => ".")
end

def change(b,l)
  total = (l - b)/b * 100
end

orgs = %w(agu anac anvisa bc cgu cvm ebc embrapa fiocruz funai ibge mapa mcid mctic mdic mds me mec mf mi minc mj mma mme mp mre ms mt mte mtur pf pr)

orgs.each do |org|
  filepath = 'data/servidores_#{org}.json'

  serialized_employees = File.read(filepath)

  employees = JSON.parse(serialized_employees)

  sum_b = 0
  sum_l = 0
  employee_count = 0
  porcentage_positive = []

  employees.each do |employee|

    salary_b = strFormat(employee['salary_b']).to_f
    salary_l = strFormat(employee['salary_l']).to_f

    porcentage = change(salary_b,salary_l).round(1)

    # puts "#{porcentage}% - #{employee['name']} - #{employee['job']} - #{salary_b} - #{salary_l}"
    if salary_l > 0
      sum_l += salary_l
    end

    if salary_b > 0
      sum_b += salary_b
      employee_count += 1
    end

    if porcentage > 50
      porcentage_positive << { name: employee['name'], porcentage: porcentage }
    end
  end

  puts "Médias"
  puts sum_l/employee_count
  puts sum_b/employee_count
  puts employee_count
  puts employees.count
  puts
  puts "Variação acima de 50%"
  porcentage_positive.each do |employee|
    puts "#{org} - #{employee[:name]} - #{employee[:porcentage]}"
  end
end
