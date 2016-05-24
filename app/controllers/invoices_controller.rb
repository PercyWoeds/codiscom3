class InvoicesController < ApplicationController
before_action :authenticate_user!
	def index
        #@invoices = Invoice.joins(:client).select("invoices.*,clients.vrazon2 as client_name").where("Invoices.cliente=Clients.Vcodigo")
        #@invoices = Invoice.paginate(:page => params[:page], :per_page => 20)
        #@invoices = Invoice.all	    
        @invoices = Invoice.paginate(:page => params[:page], :per_page => 20).find_by_sql('Select invoices.*,clients.vrazon2 from invoices INNER JOIN clients ON clients.vcodigo= invoices.cliente')
        #@invoices = @invoices.paginate(:page => params[:page], :per_page => 20)


    end
    
	def import
       Invoice.delete_all 
	   Invoice.import(params[:file])
       redirect_to root_url, notice: "Facturas importadas."
    end 
    def show
    	@invoice        = Invoice.find(params[:id])
        @list           = Invoice.find_by_sql([' Select invoices.*,clients.vrazon2,clients.vdireccion,clients.vdistrito,clients.vprov,clients.vdep  from invoices INNER JOIN clients ON clients.vcodigo= invoices.cliente where invoices.id = ?',params[:id] ] )
        
        $lg_fecha       = @invoice.fecha 
        $lg_serial_id   = @invoice.numero.to_i 
        $lcCantidad     = @invoice.cantidad   
        $lcClienteInv   = @invoice.cliente   
        $lcRuc          = @invoice.ruc    

        $lcLegalName    = @list[0].vrazon2    
        $lcDirCli       = @list[0].vdireccion   
        $lcDisCli       = @list[0].vdistrito
        $lcProv         = @list[0].vprov
        $lcDep          = @list[0].vdep

        #$lcPrecioSIgv1  =  @invoice.preciosigv * 100
        #$lcPrecioSIgv   =  $lcPrecioSIgv1.round(0)
        
        $lcPrecioCigv1  =  @invoice.preciocigv * 100
        $lcPrecioCigv2   = $lcPrecioCigv1.round(0).to_f
        $lcPrecioCigv   =  $lcPrecioCigv2.to_i 

        $lcPrecioSigv1  =  @invoice.preciosigv * 100
        $lcPrecioSigv2   = $lcPrecioSigv1.round(0).to_f
        $lcPrecioSIgv   =  $lcPrecioSigv2.to_i 
        
        $lcVVenta1      =  @invoice.vventa * 100        
        $lcVVenta       =  $lcVVenta1.round(0)
            
        $lcIgv1         =  @invoice.igv * 100
        $lcIgv          =  $lcIgv1.round(0)
        
        $lcTotal1       =  @invoice.importe * 100
        $lcTotal        =  $lcTotal1.round(0)

        #@clienteName1   = Client.where("vcodigo = ?",params[ :$lcClienteInv ])        
        $lcClienteName = ""

        #$lcGuiaRemision ="NRO.CUENTA BBVA BANCO CONTINENTAL : 0244-0100023293"
        $lcGuiaRemision =@invoice.guia     
        
    end

    def sendsunat
    
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

        case_3 = InvoiceGenerator.new(1, 3, 1, "FF01").with_igv(true)

        $lcGuiaRemision =""
        @@document_serial_id =""
        $lg_serial_id=""

    end

    def print
       
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

        case_3 = InvoiceGenerator.new(1, 3, 1, "FF01").with_igv2(true)
        $lcFileName1=File.expand_path('../../../', __FILE__)+ "/"+$lcFileName
        puts $lcFileName1
        puts lib

   #     send_data("#{$lcFileName1}" , type: "application/pdf", disposition: "attachment;
    #    filename= #{$lcFileName1} ")

        send_file("#{$lcFileName1}", :type => 'application/pdf', :disposition => 'inline')


        $lcGuiaRemision =""
        @@document_serial_id =""
        $aviso=""
    end 
        
    def borrarregistro
        
    end

    def download
        extension = File.extname(@asset.file_file_name)
        send_data open("#{@asset.file.expiring_url(10000, :original)}").read, filename: "original_#{@asset.id}#{extension}", type: @asset.file_content_type
    end

    private
    def validate_user
        redirect_to  new_user_session_path, notice: "Necesitas iniciar sesión ..."
    end

end


