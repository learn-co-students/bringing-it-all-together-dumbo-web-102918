require "pry"

class Dog

attr_accessor :name, :breed, :id

def initialize(hash)
  @name = hash[:name]
  @breed = hash[:breed]
  @id = hash[:id]
end

def self.create_table
  sql = <<-SQL
  CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
  )
  SQL
  DB[:conn].execute(sql)
end

def self.drop_table
  DB[:conn].execute("DROP TABLE IF EXISTS dogs")
end

def save
  sql = <<-SQL
  INSERT INTO dogs (name,breed) VALUES (?,?)
  SQL
  DB[:conn].execute(sql,name,breed)
  @id = DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1").flatten[0]
  self
end

def self.create (att_hash)
  new_dog = self.new(att_hash)
  new_dog.save
end

def self.find_by_id(num)
  sql = <<-SQL
  SELECT * FROM dogs WHERE id = ?
  SQL
  row = DB[:conn].execute(sql,num).flatten
  Dog.new({id: row[0], name: row[1], breed: row[2]})
end

def self.find_or_create_by(attr_hash)
  Dog.create(attr_hash)

  sql = <<-SQL
  SELECT * FROM dogs WHERE name = ? AND breed = ?
  SQL
  row = DB[:conn].execute(sql,attr_hash[:name],attr_hash[:breed]).flatten

  self.find_by_id(row[0])
end

def self.new_from_db(row)
  Dog.new({id: row[0], name: row[1], breed: row[2]})
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT id FROM dogs WHERE name = ?
  SQL
  id = DB[:conn].execute(sql,name).flatten[0]
  self.find_by_id(id)
end

def update
  sql = <<-SQL
  UPDATE dogs SET name = ?, breed = ? WHERE id = ?
  SQL
  DB[:conn].execute(sql,name,breed,id)
end

end
