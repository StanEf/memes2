# Hash cleaner
class Hash
  def clean!
    self.delete_if do |key, val|
      if block_given?
        yield(key,val)
      else
        # Prepeare the tests
        test1 = val.nil?
        test2 = val === 0
        test3 = val === false
        test4 = val.empty? if val.respond_to?('empty?')
        test5 = val.strip.empty? if val.is_a?(String) && val.respond_to?('empty?')

        # Were any of the tests true
        test1 || test2 || test3 || test4 || test5
      end
    end

    self.each do |key, val|
      if self[key].is_a?(Hash) && self[key].respond_to?('clean!')
        if block_given?
          self[key] = self[key].clean!(&Proc.new)
        else
          self[key] = self[key].clean!
        end
      end
    end

    return self
  end
end
