# TODO: AddressStandardization _can_ handle up to 5 addresses at once and each
#       can be valid or error out. Currently the system raises an exception if any
#       are invalid. The error should be by address.
module USPS::Response
  class AddressStandardization < Base
    def initialize(addresses, xml)
      @addresses = {}

      [addresses].flatten.each_with_index do |addy, i|
        @addresses[addy] = parse(xml.search("Address[@ID='#{i}']"))

        # Name is not sent nor received so lets make sure to set it so the
        # standardized version is roughly equivalent
        @addresses[addy].name = addy.name
      end
    end

    # Returns an address representing the standardized version of the given
    # address from the results of the query.
    def get(address)
      @addresses[address]
    end
    alias :[] :get
    
    def addresses
      @addresses
    end
    
    def to_h
      hash = {}
      @addresses.each_pair do |key, value|
        hash[key.to_h] = value.to_h
      end
      
      hash
    end

    private
    def parse(node)
      USPS::Address.new(
        :company => node.search('FirmName').text,
        :address1 => node.search('Address2').text,
        :address2 => node.search('Address1').text,
        :city => node.search('City').text,
        :state => node.search('State').text,
        :zip5 => node.search('Zip5').text,
        :zip4 => node.search('Zip4').text,
        :return_text => node.search('ReturnText').text,
        :additional_info => {
          :delivery_point => node.search('DeliveryPoint').text,
          :carrier_route => node.search('CarrierRoute').text,
          :footnotes => node.search('Footnotes').text,
          :dpv_confirmation => node.search('DPVConfirmation').text,
          :dpv_cmra => node.search('DPVCMRA').text,
          :dpv_footnotes => node.search('DPVFootnotes').text,
          :business => node.search('Business').text,
          :central_delivery_point => node.search('CentralDeliveryPoint').text,
          :vacant => node.search('Vacant').text
        }
      )
    end
  end
end
