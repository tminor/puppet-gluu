module PuppetX::Gluu::Helpers::Api
  def puppet_to_api(obj, context)
    type_attrs = context.type.attributes
    to_api = {}
    obj.each do |k, v|
      if type_attrs[k][:alias]
        to_api[type_attrs[k][:alias]] = v
      else
        to_api[k.to_s] = v
      end
    end
    to_api.delete('ensure')
    to_api.to_json
  end

  def api_to_puppet(obj, context)
    type_attrs = context.type.attributes
    to_puppet = {}
    obj.each do |k, v|
      attr = type_attrs.find { |key, _| type_attrs[key][:alias] == k }
      if attr
        to_puppet[attr.first] = v
      elsif type_attrs[k.to_sym]
        to_puppet[k.to_sym] = v
      end
    end

    to_puppet
  end
end
