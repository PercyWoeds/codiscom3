class Invoice < ActiveRecord::Base

	belongs_to :client, :class_name=> 'Client',    :foreign_key=> 'cliente'

	attr_accessible :cant1, :cant2, :cantidad, :cliente, :fecha, :guia, :igv, :importe, :moneda, :numero, :preciocigv, :preciosigv, :ruc, :serie, :td, :vventa

        def self.import(file)
          CSV.foreach(file.path, headers: true) do |row|
          Invoice.create! row.to_hash 
        end

      end 

      def enviarsunat      	
       case_3 = InvoiceGenerator.new(1, 3, 1, "FF01").with_igv(true) 
      end

      def client_name
        read_attribute(client_name) || client.vrazon2
      end

end

