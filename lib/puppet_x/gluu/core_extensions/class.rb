module PuppetX::Gluu::CoreExtensions::Class
  refine Class do
    # Makes class instance variables inheritable (and mutable by
    # subclasses).
    #
    # See: https://stackoverflow.com/a/4126296
    def class_attr_accessor(*args)
      args.each do |arg|
        singleton_class.send(:define_method, arg.to_s) do
          instance_variable_get("@#{arg}")
        end

        singleton_class.send(:define_method, "#{arg}=") do |val|
          instance_variable_set("@#{arg}", val)
        end

        define_method arg do
          self.class.superclass.send(arg)
        end

        define_method "#{arg}=" do |val|
          self.class.superclass.send("#{arg}=", val)
        end
      end
    end
  end
end
