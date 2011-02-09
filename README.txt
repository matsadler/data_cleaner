= DataCleaner

DataCleaner is a library to aid you in anonymising your data, for example when attempting to reproduce a bug in development, and only live data will do, but it's not safe to have a whole database of customer names, email, etc on your development machine.

DataCleaner wants to make sure your data still looks real, and importantly, passes any validation your code might have. To achieve this it provides a DSL for you to specify the format of the data, along with helpers (using the faker gem) to generate common data.

Only data that need anonymising needs to be specified, foreign keys, non-customer-identifiable data should be left alone.

* rdoc[http://sourcetagsandcodes.com/data_cleaner/doc/]
* source[https://github.com/matsadler/data_cleaner]

== Installation

gem install data_cleaner

== Usage
  
  require 'rubygems'
  require 'data_cleaner'
  
  class TopSecret
    attr_accessor :name, :email, :reference, :secret, :date
    
    def initialize(name, email, reference, secret, date)
      @name = name
      @email = email
      @reference = reference
      @secret = secret
      @date = date
    end
    
    def valid?
      name.match(/^[a-z]+ [a-z]+$/i) &&
      reference.match(/^[a-z]{3}[0-9]{1,5}$/) &&
      date.is_a?(Time) || false
    end
    
  end
  
  module DataCleaner::Formats
    helper :embarrassing_secret do
      "I like " + ["the colour pink", "programming PHP", "Judas Priest"].sample
    end
    
    format "TopSecret" do |f|
      f.name [:first_name, " ", :last_name]
      f.email :email, &:name # passes the objects name to the email method
      f.reference do |obj| # one off helper
        "#{obj.name[0..2].downcase}#{obj.date.strftime("%y")}"
      end
      f.secret :embarrassing_secret
    end
  end
  
  secret = TopSecret.new("Matthew Sadler", "mat@foo.com", "mat09", "I like kittens", Time.now)
  puts secret.inspect
  puts "is valid? #{secret.valid?}"
  puts
  
  clean = DataCleaner::Cleaner.clean!(secret)
  
  puts clean.inspect
  puts "is valid? #{clean.valid?}"

prints:
  
  #<TopSecret:0x1015f7830 @email="mat@foo.com", @date=Mon Jan 17 16:53:19 +0000 2011, @name="Matthew Sadler", @secret="I like kittens", @reference="mat09">
  is valid? true
  
  #<TopSecret:0x1015f7830 @email="javier.kuhlman@franeckikonopelski.co.uk", @date=Mon Jan 17 16:53:19 +0000 2011, @name="Javier Kuhlman", @secret="the colour pink", @reference="jav11">
  is valid? true

== Formats
There are various ways of specifying the format of an attribute.

=== Basic Symbol

  format "TopSecret" do |f|
    f.name :first_name
  end
In this case the helper :first_name will be used to replace the name attribute

=== Symbol With Arguments

  format "TopSecret" do |f|
    f.email :email, "Arthur"
  end
The helper :email will be used to replace the attribute, and be given the argument "Arthur"

=== Symbol With Block

  format "TopSecret" do |f|
    f.name :first_name
    f.email(:email) {|obj| obj.name}
  end
In this example the :email helper will be given the objects replacement name as an argument

  format "TopSecret" do |f|
    f.email(:email) {|obj| obj.name}
    f.name :first_name
  end
Here the :email helper will get the objects original name as an argument

=== String

  format "TopSecret" do |f|
    f.name "Arthur"
  end
In this case the name will simply be replaced with the string specified

=== Array

  format "TopSecret" do |f|
    f.name [:first_name, " ", :last_name]
  end
With an array the individual elements behave like those above, then they are concatenated together, in this example the results from the :first_name and :last_name helpers will be joined with the string " " between them

=== Nested Arrays

   format "TopSecret" do |f|
     f.emails [[:email, "Arthur"], ", ", [:email, "Ford"]]
   end
In this example the :email helper will be called twice, once with the argument "Arthur", then again with the argument "Ford", and these will be joined by the string ", "

=== Block

  format "TopSecret" do |f|
    f.secret {|obj| rand(100)}
  end
When using a block the attribute will be replaced by the result of the block.

== Built-in helpers
The built-in helpers use the faker gem to generate data, see the faker documentation for more details

:name
:first_name
:last_name
:name_prefix
:name_suffix

:phone_number

:city
:city_prefix
:city_suffix
:secondary_address
:street_address
:street_name
:street_suffix
:uk_country
:uk_county
:uk_postcode
:us_state
:us_state_abbr
:zip_code

:domain_name
:domain_suffix
:domain_word
:email
:free_email
:user_name

:bs
:catch_phrase
:company_name
:company_suffix

:paragraph
:paragraphs
:sentence
:sentences
:words

== Custom helpers
Custom helpers can be defined like 

  module DataCleaner::Formats
    helper :embarrassing_secret do
      "I like " + ["the colour pink", "programming PHP", "Judas Priest"].sample
    end
  end

This can also be used to redefine the built-in helpers.

== Licence

(The MIT License)

Copyright © 2011 Matthew Sadler

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.