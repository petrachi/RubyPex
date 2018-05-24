if ARGV[0] == '--soluce'
  module RKit
    module Override
      Dir[File.join(File.dirname(__FILE__), "soluce", "*.rb")].each do |file|
        require file
      end
    end
  end

else
  module Override
    Dir[File.join(File.dirname(__FILE__), "override", "*.rb")].each do |file|
      require file
    end
  end
end

begin
  print "Override : "
rescue
  print "\nNOK"
end

class InjectionTest
  def result
    "NOK"
  end

  override_method :result do
    __olddef__[1..-1]
  end
end

begin
  print "\nIt override a method defined in the same class (injection) : #{ InjectionTest.new.result }"
rescue
  print "\nNOK"
end

class Inherited
  def result
    "NOK"
  end
end

class InheritanceTest < Inherited
  override_method :result do
    __olddef__[1..-1]
  end
end

begin
  print "\nIt override a method defined via inheritance : #{ InheritanceTest.new.result }"
rescue
  print "\nNOK"
end


module Included
  def result
    "NOK"
  end
end

class IncludeTest
  include Included

  override_method :result do
    __olddef__[1..-1]
  end
end

begin
  print "\nIt override a method in an included module : #{ IncludeTest.new.result }"
rescue
  print "\nNOK"
end

module Prepended
  override_method :result do
    __olddef__[1..-1]
  end
end

class PrependTest
  prepend Prepended

  def result
    "NOK"
  end
end

begin
  print "\nIt override a method in a prepended module : #{ PrependTest.new.result }"
rescue
  print "\nNOK"
end

class DelegatedTo
  def result
    "NOK"
  end
end

class DelegatorTest < SimpleDelegator
  override_method :result do
    __olddef__[1..-1]
  end
end

begin
  print "\nIt override a method defined thought delegation : #{ DelegatorTest.new(DelegatedTo.new).result }"
rescue
  print "\nNOK"
end

class ErrorTest
  override_method :result do
    __olddef__ || "OK"
  end
end

begin
  print "\nIt return nil if previous definition does not exist : #{ ErrorTest.new.result }"
rescue
  print "\nNOK"
end


class ChainTest
  def result
    "N"
  end

  override_method :result do
    __olddef__ << "OK"
  end

  override_method :result do
    __olddef__[1..-1]
  end
end

begin
  print "\nIt can chain overrides : #{ ChainTest.new.result }"
rescue
  print "\nNOK"
end

class ArgumentTest
  def result str
    str << "NOK"
  end

  override_method :result do |str|
    __olddef__(str) << ', I mean, is it OK !'
  end
end

begin
  print "\nIt can override w/ arguments : #{ ArgumentTest.new.result('it is ') }"
rescue
  print "\nNOK"
end

class ManyTest
  def result
    "NO"
  end

  def other_result
    "NK"
  end

  override_methods do
    def result
      __olddef__[1..-1]
    end

    def other_result
      __olddef__[1..-1]
    end
  end
end

begin
  print "\nIt can override many methods at the same time : #{ ManyTest.new.result }#{ ManyTest.new.other_result }"
rescue
  print "\nNOK"
end

class PatternTest
  def initialize bool
    @bool = bool
  end

  def should?
   @bool
  end

  def result
    "NO"
  end

  depend_pattern = ->{
    if should?
      __newdef__
    else
      "K"
    end
  }

  override_method :result, pattern: depend_pattern do
    __olddef__[1..-1]
  end
end

begin
  print "\nIt can override a method based on a pattern : #{ PatternTest.new(true).result }#{ PatternTest.new(false).result }"
rescue
  print "\nNOK"
end

class InstanceTest
  def initialize
    @should_load = true
  end

  def load
    "not implemented"
  end

  override_method :load do
    if @should_load
      @should_load = false
      "load"
    else
      "nothing"
    end
  end
end

inst = InstanceTest.new
begin
  print "\nIt can access and change instance variables : #{ inst.load == 'load' } #{ inst.load == 'nothing' }"
rescue
  print "\nNOK"
end

class SelfTest
  def initialize
    @loaded = false
  end

  def loaded?
    @loaded
  end

  def load
    "not implemented"
  end

  override_method :load do
    @loaded = true
    self
  end
end

inst = SelfTest.new
begin
  print "\nIt can access self : #{ inst.loaded? == false } #{ inst.load.loaded? == true }"
rescue
  print "\nNOK"
end

class ArrowTest
  class << self
    def result
      "NOK"
    end

    override_method :result do
      __olddef__[1..-1]
    end
  end
end

begin
  print "\nIt override a singleton method defined using << syntax : #{ ArrowTest.result }"
rescue
  print "\nNOK"
end

class SingletonTest
  def self.result
    "NOK"
  end

  override_methods do
    def self.result
      __olddef__[1..-1]
    end
  end
end

begin
  print "\nIt override a singleton method defined using self. syntax : #{ SingletonTest.result }"
rescue
  print "\nNOK"
end

class SpecialTest
  def self.result
    "NOK"
  end

  override_singleton_method :result do
    __olddef__[1..-1]
  end
end

begin
  print "\nIt override a singleton method using special override method : #{ SpecialTest.result }"
rescue
  print "\nNOK"
end

class NestedTest
  def self.meta_define method_name
    singleton_class.send :define_method, method_name do
      method_name
    end
  end

  override_singleton_method :meta_define do |name|
    __olddef__(name).tap do |other_name|
      override_singleton_method other_name do
        __olddef__ << other_name.to_s
      end
    end
  end

  meta_define 'ok'
  meta_define 'yes'
end

begin
  print "\nIt can be nested in some weird ways : #{ NestedTest.ok == 'okok' } #{ NestedTest.yes == 'yesyes' }"
rescue
  print "\nNOK"
end

begin
  print "\n"
rescue
  print "\nNOK"
end
