require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end #end method


  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end


  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  #save
  #saves an instance of the Student class to the database
  #and then sets the given students `id` attribute

  def save
    if self.persisted? #if instance exists...
      self.update
    else #if it doesn't exist...
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end #end if...else statement
  end


  def persisted?
    !!self.id
  end


  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end


  def self.new_from_db(row)
    # create a new Student object given a row from the database
    id = row[0]
    name = row[1]
    grade = row[2]
    new_student = self.new(name, grade, id) # self.new is the same as running Student.new
    new_student  # return the newly created instance
  end


  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    array_of_rows = DB[:conn].execute(sql,name)
    array_of_rows.map do |row|
      self.new_from_db(row)
    end.first #returns first from array created by map
  end #end method



end #end class
