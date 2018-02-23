    class VoidedsController < ApplicationController


	def new
		@voided = Voided.new();
	end

	def read
		@voided = Voided.find(1);
	end

    def correlativo
        voided= Voided.new()
        voided.numero=Voided.find(1).numero.to_i + 1
        lcnumero=voided.numero.to_s
        Voided.where(:id=>'1').update_all(:numero =>lcnumero)
    end
    
    def anular 
        lib = File.expand_path('../../../lib', __FILE__)
        $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

        require 'sunat'
        require './config/config'
        require './app/generators/invoice_generator'
        require './app/generators/credit_note_generator'
        require './app/generators/debit_note_generator'
        require './app/generators/receipt_generator'
        require './app/generators/daily_receipt_summary_generator'
        require './app/generators/voided_documents_generator'

        SUNAT.environment = :production

        files_to_clean = Dir.glob("*.xml") + Dir.glob("./app/pdf_output/*.pdf") + Dir.glob("*.zip")
        files_to_clean.each do |file|
          File.delete(file)
        end 

        VoidedDocumentsGenerator.new.generate
        
        $lcFileName2=File.expand_path('../../../', __FILE__)+ "/"+$lcFileName

        send_file("#{$lcFileName2}", :type => 'application/pdf', :disposition => 'inline')

        voided= Voided.new()
        voided.numero=Voided.find(1).numero.to_i + 1
        lcnumero=voided.numero.to_s
        Voided.where(:id=>'1').update_all(:numero =>lcnumero)
        
    end     
 def anular2
        lib = File.expand_path('../../../lib', __FILE__)
        $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

        require 'sunat'
        require './config/config'
        require './app/generators/invoice_generator'
        require './app/generators/credit_note_generator'
        require './app/generators/debit_note_generator'
        require './app/generators/receipt_generator'
        require './app/generators/daily_receipt_summary_generator'
        require './app/generators/voided_documents_generator'

        SUNAT.environment = :production

        files_to_clean = Dir.glob("*.xml") + Dir.glob("./app/pdf_output/*.pdf") + Dir.glob("*.zip")
        files_to_clean.each do |file|
          File.delete(file)
        end 

        VoidedDocumentsGenerator.new.generate2
        
        if $lcValido == "1"

        $lcFileName2=File.expand_path('../../../', __FILE__)+ "/"+$lcFileName

        send_file("#{$lcFileName2}", :type => 'application/pdf', :disposition => 'inline')

        voided= Voided.new()
        voided.numero=Voided.find(1).numero.to_i + 1
        lcnumero=voided.numero.to_s
        Voided.where(:id=>'1').update_all(:numero =>lcnumero)
        end 
        
end 


end
