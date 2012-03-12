$LOAD_PATH << File.expand_path('../../', __FILE__)
require 'spec_helper'

describe Robotwitter do
  def mock_client(object)
    @mock = MiniTest::Mock.new
    object.instance_variable_set(:@client, @mock)
  end
  before do
    @robotwitter = Robotwitter::Robot.new('', 'test_login') do
      'hello'
    end
    mock_client(@robotwitter)
  end

  # мы фалловим 5 пользователей: [4,5,6,7,8]
  # нас фалловят 4: [1,2,3,4]
  # follow_all_back должна зафалловить 3х пользователей: [1,2,3]
  describe 'follow_all_back' do
    before do
      ids = [1,2,3,4]
      @mock.expect(:follower_ids, 'ids' => ids)
      @mock.expect(:friend_ids,   'ids' => [4,5,6,7,8])
      ids.pop
      ids.each { |id| @mock.expect(:follow, [], [id]) }
    end

    it 'should follow those, who follows me' do
      @robotwitter.follow_all_back
      @mock.verify
    end
  end

  # тестируем отправку сообщений
  # перед отправкой сообщение получается из внешнего источника
  describe 'send_message' do
    before do
      @mock.expect(:update, nil, ['hello there'])
    end

    it 'should successfully sends message' do
      @robotwitter.send_message('_msg_ there')
      @mock.verify
    end
  end

  # тестируем ретвит о каком-то слове
  # сначала мокаем search_client
  # он вызывает кучу методов через method chaining и возвращает id твитта,который нужно ретвитнуть
  # потом мокаем сохраниение в базе
  describe 'retweet_about' do
    before do
      sk = MiniTest::Mock.new
      sk.expect(:containing,  sk, %w/hell/)
      sk.expect(:locale,      sk, %w/ru/)
      sk.expect(:no_retweets, sk)
      sk.expect(:per_page,    sk, [2])
      sk.expect(:fetch,       ['id' => 'kolyan'])

      db = MiniTest::Mock.new
      db.expect(:nil?, false)
      db.expect(:retweeted?, false, ['id' => 'kolyan'])
      db.expect(:save_retweet, false, ['id' => 'kolyan'])

      @robotwitter.instance_variable_set(:@search_client, sk)
      @robotwitter.instance_variable_set(:@db, db)
      @mock.expect(:retweet, nil, %w/kolyan/)
    end

    it 'should retweet' do
      @robotwitter.retweet_about('hell')
      @mock.verify
    end
  end
end