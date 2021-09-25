module PuppetX::Gluu::Hooks
  def around(*syms, before_do:, after_do:)
    syms.each do |sym|
      str_id = "__#{sym}__hooked__"

      next if send(:private_instance_methods).include?(str_id)

      singleton_class.send(:define_method, sym) { |*args| } unless method_defined? sym

      singleton_class.send(:alias_method, str_id, sym)
      singleton_class.send(:private, str_id)
      singleton_class.send :define_method, sym do |*args|
        before_do.call(self, *args)
        ret = send str_id, *args
        after_do.call(self, *args)
        ret
      end
    end
  end

  def self.included(base)
    base.extend(self)
  end
end
