require 'pry'
class Dog
  attr_accessor :id, :name, :breed

  def initialize(args = {})
    options = defaults.merge(args)
    @id = options.fetch(:id)
    @name = options.fetch(:name)
    @breed = options.fetch(:breed)
  end

  def defaults
    {
      id: nil,
      name: nil,
      breed: nil
    }
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute sql
  end

  def self.drop_table
    DB[:conn].execute "DROP TABLE dogs"
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute sql, @name, @breed
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.create(params = {})
    dog_obj = Dog.new(params)
    dog_obj.save
  end

  def self.find_by_id(arg)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, arg)[0]
    Dog.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_or_create_by(params)
    Dog.create(params)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, params[:name], params[:breed]).flatten
    self.find_by_id(row[0])
  end
  
  def self.new_from_db(row)
    Dog.create(id: row[0], name: row[1], breed: row[2])
  end
end
