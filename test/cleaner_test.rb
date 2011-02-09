base = File.expand_path(File.dirname(__FILE__) + '/../lib')
require base + '/data_cleaner'
require 'test/unit'

TopSecret = Struct.new(:name, :email, :reference, :secret, :date)

class CleanerTest < Test::Unit::TestCase
  
  def setup
    @secret = TopSecret.new("Arthur Dent", "arthur@milliways.com", "H2G2", 42, Date.new(1978, 3, 8))
  end
  
  def teardown
    DataCleaner::Formats.formats.clear
  end
  
  def test_simple_format
    DataCleaner::Formats.format "TopSecret" do |f|
      f.name :first_name
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal("Arthur Dent", clean.name)
    assert_match(/^[A-Z]'?[a-z]+$/, clean.name)
  end
  
  def test_static_replacment
    DataCleaner::Formats.format "TopSecret" do |f|
      f.name "Ford Prefect"
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal("Arthur Dent", clean.name)
    assert_equal("Ford Prefect", clean.name)
  end
  
  def test_array_format
    DataCleaner::Formats.format "TopSecret" do |f|
      f.name [:first_name, " ", :last_name]
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal("Arthur Dent", clean.name)
    assert_match(/^[A-Z]'?[a-z]+ [A-Z]'?[A-Za-z]+$/, clean.name)
  end
  
  def test_format_with_argument
    DataCleaner::Formats.format "TopSecret" do |f|
      f.email :email, "test"
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal("arthur@milliways.com", clean.email)
    assert_match(/^test@/, clean.email)
  end
  
  def test_format_with_block_argument
    DataCleaner::Formats.format "TopSecret" do |f|
      f.email(:email) {|obj| obj.name.split.first}
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal("arthur@milliways.com", clean.email)
    assert_match(/^arthur@/, clean.email)
  end
  
  def test_array_format_with_arguemnts
    DataCleaner::Formats.format "TopSecret" do |f|
      f.email [[:email, "test"], ", ", [:email, Proc.new {|obj| obj.name.split.first}]]
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal("arthur@milliways.com", clean.email)
    assert_match(/^test@[^,]+, arthur@/, clean.email)
  end
  
  def test_block_format
    DataCleaner::Formats.format "TopSecret" do |f|
      f.name {|obj| obj.name.reverse}
      f.email {|obj| obj.email.gsub(/@/, " AT ").gsub(/\./, " DOT ")}
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal("Arthur Dent", clean.name)
    assert_equal("tneD ruhtrA", clean.name)
    
    assert_not_equal("arthur@milliways.com", clean.email)
    assert_equal("arthur AT milliways DOT com", clean.email)
  end
  
  def test_helper
    DataCleaner::Formats.helper :date do
      Date.today
    end
    
    DataCleaner::Formats.format "TopSecret" do |f|
      f.date :date
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal(Date.new(1978, 3, 8), clean.date)
    assert_equal(Date.today, clean.date)
  end
  
  def test_helper_with_arguments
    DataCleaner::Formats.helper :date do |year, month, day|
      Date.new(year, month, day)
    end
    
    DataCleaner::Formats.format "TopSecret" do |f|
      f.date :date, 2004, 4, 28
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal(Date.new(1978, 3, 8), clean.date)
    assert_equal(Date.new(2004, 4, 28), clean.date)
  end
  
  def test_clean
    DataCleaner::Formats.format "TopSecret" do |f|
      f.name [:first_name, " ", :last_name]
      f.email :email, &:name
      f.secret {|obj| rand(41)}
      f.date {|obj| Date.today}
    end
    
    clean = DataCleaner::Cleaner.clean(@secret)
    
    assert_not_equal("Arthur Dent", clean.name)
    assert_match(/^[A-Z]'?[a-z]+ [A-Z]'?[A-Za-z]+$/, clean.name)
    
    assert_not_equal("arthur@milliways.com", clean.email)
    
    assert_not_equal(42, clean.secret)
    assert(clean.secret >= 0 && clean.secret <= 41)
    
    assert_not_equal(Date.new(1978, 3, 8), clean.date)
    assert_equal(Date.today, clean.date)
    
    assert_equal("Arthur Dent", @secret.name)
  end
  
  def test_clean!
    DataCleaner::Formats.format "TopSecret" do |f|
      f.name [:first_name, " ", :last_name]
      f.email :email, &:name
      f.secret {|obj| rand(41)}
      f.date {|obj| Date.today}
    end
    
    DataCleaner::Cleaner.clean!(@secret)
    
    assert_not_equal("Arthur Dent", @secret.name)
    assert_match(/^[A-Z]'?[a-z]+ [A-Z]'?[A-Za-z]+$/, @secret.name)
    
    assert_not_equal("arthur@milliways.com", @secret.email)
    
    assert_not_equal(42, @secret.secret)
    assert(@secret.secret >= 0 && @secret.secret <= 41)
    
    assert_not_equal(Date.new(1978, 3, 8), @secret.date)
    assert_equal(Date.today, @secret.date)
  end
  
  def test_include
    DataCleaner::Formats.format "TopSecret" do |f|
      f.name [:first_name, " ", :last_name]
      f.email :email, &:name
      f.secret {|obj| rand(41)}
      f.date {|obj| Date.today}
    end
    
    class << @secret
      include DataCleaner::Cleaner
    end
    
    @secret.clean!
    
    assert_not_equal("Arthur Dent", @secret.name)
    assert_match(/^[A-Z]'?[a-z]+ [A-Z]'?[A-Za-z]+$/, @secret.name)
    
    assert_not_equal("arthur@milliways.com", @secret.email)
    
    assert_not_equal(42, @secret.secret)
    assert(@secret.secret >= 0 && @secret.secret <= 41)
    
    assert_not_equal(Date.new(1978, 3, 8), @secret.date)
    assert_equal(Date.today, @secret.date)
  end
  
  def test_clean_value
    DataCleaner::Formats.format "TopSecret" do |f|
      f.name [:first_name, " ", :last_name]
      f.email :email
      f.secret "test"
    end
    
    name = DataCleaner::Cleaner.clean_value(:name, TopSecret)
    email = DataCleaner::Cleaner.clean_value(:email, TopSecret)
    secret = DataCleaner::Cleaner.clean_value(:secret, TopSecret)
    
    assert_match(/^[A-Z]'?[a-z]+ [A-Z]'?[A-Za-z]+$/, name)
    assert_match(/[a-z]+@[a-z]+.[a-z]/, email)
    assert_equal("test", secret)
  end
  
end