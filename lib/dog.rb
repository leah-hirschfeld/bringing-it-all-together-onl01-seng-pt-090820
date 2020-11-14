class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql =  <<-SQL
     CREATE TABLE IF NOT EXISTS dogs (
       id INTEGER PRIMARY KEY,
       name TEXT,
       breed TEXT
       )
       SQL
   DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
     DROP TABLE dogs
       SQL
   DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(attributes)
   dog = Dog.new(attributes)
   dog.save
   dog
 end

 def self.new_from_db(attributes)
   new_dog = self.new
   new_dog.id = attributes[0]
   new_dog.name = attributes[1]
   new_dog.breed = attributes[2]
   new_dog
 end

 def self.find_by_id(name:, breed:)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(result[0], result[1], result[2])
  end

  def self.find_by_name(name:)
   sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE name = ?
     LIMIT 1
   SQL

   DB[:conn].execute(sql, name).map do |row|
     self.new_from_db(row)
   end.first
 end

  def self.find_or_create_by(id:, name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def update(id:, name:, breed:)
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.id, self.name, self.breed)
  end

end
