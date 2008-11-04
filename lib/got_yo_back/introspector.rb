module GotYoBack
  class Introspector
    attr_reader :klass
    
    def initialize(klass)
      @klass = klass
      @observed_methods = { }
    end
    
    def observe_klass!
      @observed ||= begin
        this = self
        @klass.meta_def(:method_added) do |m|
          this.check_method(m)
        end and true
      end
    end
    
    def observing?(method_id)
      not not @observed_methods[method_id]
    end
    
    def observe(method_id, &block)
      observe_klass!
      @observed_methods[method_id] ||= []
      @observed_methods[method_id] << proc(&block) if block_given?
      @observed_methods[method_id].compact!
      @observed_methods[method_id].uniq!
    end
    
    def check_method(method_id)
      handlers = @observed_methods.delete(method_id)
      handlers.each { |fn| fn.call } rescue nil
      
    end
    
    def defined_methods
      (klass.instance_methods - Object.instance_methods).map(&:to_sym)
    end
  end
end