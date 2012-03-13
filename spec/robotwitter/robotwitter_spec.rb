$LOAD_PATH << File.expand_path('../../', __FILE__)
require 'spec_helper'

describe Robotwitter do
  def mock_client(object)
    @mock = MiniTest::Mock.new
    object.instance_variable_set(:@client, @mock)
  end

  def follower_and_friends
    ids = [1,2,3,4]
    @mock.expect(:follower_ids, 'ids' => ids)
    @mock.expect(:friend_ids,   'ids' => [4,5,6,7,8])
    ids
  end

  def tweet_params
    ['id' => 'kolyan', 'from_user_id' => 'vasyan_id', 'from_user' => 'vasyan']
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
      ids = follower_and_friends
      ids.pop
      ids.each { |id| @mock.expect(:follow, [], [id]) }
    end

    it 'should follow those, who follows me' do
      @robotwitter.follow_all_back
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
    end
  end

  describe 'containing' do
    # сначала мокаем search_client
    # он вызывает кучу методов через method chaining и возвращает id твитта
    before do
      sk = MiniTest::Mock.new
      sk.expect(:containing,  sk, %w/hell/)
      sk.expect(:locale,      sk, %w/ru/)
      sk.expect(:no_retweets, sk)
      sk.expect(:per_page,    sk, [2])
      sk.expect(:per_page,    sk, [5])
      sk.expect(:fetch,       tweet_params)
      @robotwitter.instance_variable_set(:@search_client, sk)
    end

    # тестируем ретвит о каком-то слове
    describe 'retweet_about' do
      # мокаем сохраниение в базе
      before do
        db = MiniTest::Mock.new
        db.expect(:nil?, false)
        db.expect(:retweeted?, false, tweet_params)
        db.expect(:save_retweet, false, tweet_params)

        @robotwitter.instance_variable_set(:@db, db)
        @mock.expect(:retweet, nil, %w/kolyan/)
      end

      it 'should retweet' do
        @robotwitter.retweet_about('hell')
      end
    end

    # тестируем фолловинг пользователей, которые пишут о...
    describe 'follow_users_tweets_about' do
      before do
        follower_and_friends
        @mock.expect(:follow, [], ['vasyan'])
      end

      it 'should follow users' do
        @robotwitter.follow_users_tweets_about('hell')
      end
    end
  end

  # мы фалловим 5 пользователей: [4,5,6,7,8]
  # нас фалловят 4: [1,2,3,4]
  # follow_all_back должна отфалловить 3х пользователей: [1,2,3]
  describe 'unfollow_users' do
    before do
      follower_and_friends
      (1..3).to_a.map {|i| @mock.expect(:unfollow, [], [i])}
    end

    it 'should unfollow' do
      @robotwitter.unfollow_users
    end
  end

  after do
    @mock.verify
  end
end