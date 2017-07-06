class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self

  end

def self.create(attributes)
  new_dog = Dog.new(attributes)
  new_dog.save
  new_dog
end

def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id).first
    if row
        new_from_db(row)
      else
        nil
    end

end

  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    row = DB[:conn].execute(sql, attributes[:name], attributes[:breed]).first
    return new_from_db(row) unless row.nil?
    create(attributes)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).first
    new_from_db(row)
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.id)
    self.class.find_by_name(self.name)
  end
end
