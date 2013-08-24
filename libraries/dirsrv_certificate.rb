class Chef
  class DirsrvCertificate 

    def initialize
      require 'chef/encrypted_data_bag_item'
    end

    def load
      if Chef::Config[:solo]
        {
          id: "certificates",
          test: {
            certname: "selfsigned",
            pin: "IAmSelfSigned",
            keysize: 2048,
            trustbits: "CT,u,u"
          }
        } 
      else
        Chef::EncryptedDataBagItem.load("dirsrv", "certificates")
      end
    end
  end
end
