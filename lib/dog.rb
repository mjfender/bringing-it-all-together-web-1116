
class Dog
  attr_accessor :name, :breed, :id

  def initialize(dog_hash={})
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = nil
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
      DROP TABLE dogs;
      )
    SQL
    DB[:conn].execute(sql)
  end


  def self.new_from_db(row)
    new_dog = self.new
    new_dog.id = row[0]
    new_dog.name =  row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.find_by_name(dog_name)
  dog_name = dog_name.split.map(&:capitalize).join(' ')
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?;
      )
    SQL
    found_dog = DB[:conn].execute(sql, dog_name).first
    new_from_db(found_dog)
  end

  def update
    sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ?
        WHERE id = ?
        SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
      self
  end

  def self.create(dog_hash)
    new_dog = Dog.new(dog_hash)
    created_dog = new_dog.save
    created_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        LIMIT 1
      SQL
      found_dog = DB[:conn].execute(sql, id).first
      dog_object = new_from_db(found_dog[0])
    end

  def self.find_or_create_by(dog_hash)
    found_dog = self.all.find do |dog|
      dog.name == dog_hash[:name] && dog.breed == dog_hash[:breed]
    end


    # sql = <<-SQL
    #     SELECT * FROM dogs
    #     WHERE name = ? AND breed = ?
    #   SQL
    #   found_dog = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])
    if found_dog.class != Dog
      found_dog = self.create(dog_hash)
    end
    found_dog
  end

  def self.all
    # find all the rows in the database
    sql = <<-SQL
    SELECT *
    FROM dogs;
    SQL
    results = DB[:conn].execute(sql)
    # create an instance for each row
    results.map do |dog_result|
      # tweet_result ==> {"id"=>1, "username"=>"coffeedad", "message"=>"good coffee"}
      # Tweet.new({"id" => tweet_result["id"], "username" => tweet_result["username"], "message" => tweet_result["message"]})
      new_from_db(dog_result)
    end
    # we need to return an array of tweet instances
    # based on what is in the database
  end


  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (? , ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)

      id_sql = <<-SQL
      SELECT id FROM dogs
      ORDER BY id DESC
      LIMIT 1
      SQL

      id_result = DB[:conn].execute(id_sql).first
      @id = id_result[0]
      self
    else
      self.update
    end
    self
  end


end