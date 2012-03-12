module Robotwitter
  class Db
    TABLENAME = 'retweeted'

    # check if database exists
    def exists?(name)
      File.exist?("#{name}.db")
    end

    # create database
    def create_db(name)
      db = SQLite3::Database.new("#{name}.db")

      sql = <<-SQL
            create table #{TABLENAME} (
              id  integer PRIMARY KEY AUTOINCREMENT,
              tweet_id string
            );
            SQL

      db.execute_batch(sql)
    end

    def initialize(name, path)
      create_db("#{path}/#{name}") unless exists? "#{path}/#{name}"
      @db = SQLite3::Database.new "#{path}/#{name}.db"
    end

    # already retweeted this post
    def retweeted? result
      sql = "select 1 from #{TABLENAME} where tweet_id = '#{result['id_str']}'"
      res = @db.get_first_row(sql)
      !res.nil?
    end

    # сохраняем ретвитт, чтобы не ретвиттить снова
    # result - результат twitter.search
    def save_retweet result
      id = result['id_str']
      sql = "insert into #{TABLENAME} (tweet_id) values (#{id})"
      @db.query(sql)
    end
  end
end