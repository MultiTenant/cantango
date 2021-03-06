require 'rspec'
require 'cantango'
require 'fixtures/models'
require 'cantango/rspec'

def config_folder
  File.dirname(__FILE__)+ "/../fixtures/config/"
end

CanTango.configure do |config|
  config.clear!
  config.engines.all :off
  config.engine(:user_ac).set :on
  config.ability.mode = :cache
  config.engine(:user_ac) do |engine|
    engine.mode = :cache
  end
  config.debug!
end

class Thingy
  attr_reader :name, :id

  def initialize name
    @name = name
    @id = rand(1000)
  end
end

describe CanTango::UserAcEngine do
  context 'mode :cache' do
    before do
      @thingy = Thingy.new 'a'
      @user = User.new 'kris'
      @permission = Permission.new @user, :edit, @thingy
      @user.permissions << @permission
    end

    describe 'Permission' do
      subject { @permission }
        its(:thing_id) { should be_a(Integer) }
    end

    let (:ability) do
      CanTango::CachedAbility.new @user
    end
    subject { CanTango::UserAcEngine.new ability }

    describe '#execute!' do
      before do
        subject.execute!
      end

      it 'engine should have rules' do
        subject.send(:rules).should_not be_empty
      end

      it 'engine cache should have rules' do
        subject.cache.empty?.should be_false
      end
    end
  end
end

