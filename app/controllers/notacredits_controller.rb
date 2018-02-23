
include ApplicationHelper

class NotacreditsController < ApplicationController
  before_action :set_notacredit, only: [:show, :edit, :update, :destroy]

  # GET /notacredits
  # GET /notacredits.json
  def index
    @notacredits = Notacredit.all
  end

  # GET /notacredits/1
  # GET /notacredits/1.json
  def show 
        @invoice        = Notacredit.find(params[:id])
        $lg_fecha       = @invoice.fecha
        $lg_fecha1      = $lg_fecha.to_s

          parts = $lg_fecha1.split("-")
          $aa = parts[0].to_i
          $mm = parts[1].to_i        
          $dd = parts[2].to_i        
          puts $dd 
          puts $mm
          puts $aa 

         parts = @invoice.code.split("-")        
          id = parts[0]
          compen    = parts[1]        
          
        $lcNumeroNota = @invoice.code  
        $lcBillingReference = @invoice.mod_factura

        $lg_serial_id   = parts[1]
        $lg_serial_id2  = parts[1]

        $lcCantidad     = @invoice.quantity   
        $lcClienteInv   = @invoice.client.vrazon2   
        $lcRuc          = @invoice.client.vruc    
        
        if @invoice.nota_id == 1
            $lcTd           = "NC"
        else
            $lcTd           = "ND"
        end  
        

        $lcMail         = @invoice.client.mailclient
        $lcMail2        = @invoice.client.mailclient2
        $lcMail3        = @invoice.client.mailclient3
        $lcLegalName    = @invoice.client.vrazon2    
        $lcDirCli       = @invoice.client.vdireccion   
        $lcDisCli       = @invoice.client.vdistrito
        $lcProv         = @invoice.client.vprov
        $lcDep          = @invoice.client.vdep

        $lcPrecioCigv1  =  @invoice.price * 100
        $lcPrecioCigv2   = $lcPrecioCigv1.round(0).to_f
        $lcPrecioCigv   =  $lcPrecioCigv2.to_i 

        $lcPrecioSigv1  =  (@invoice.price / 1.18) * 100
        $lcPrecioSigv2   = $lcPrecioSigv1.round(0).to_f
        $lcPrecioSIgv   =  $lcPrecioSigv2.to_i 
        
        $lcVVenta1      =  @invoice.subtotal * 100        
        $lcVVenta       =  $lcVVenta1.round(0)
            
        $lcIgv1         =  @invoice.tax * 100
        $lcIgv          =  $lcIgv1.round(0)
        
        $lcTotal1       =  @invoice.total * 100
        $lcTotal        =  $lcTotal1.round(0)

        #@clienteName1   = Client.where("vcodigo = ?",params[ :$lcClienteInv ])        
        $lcClienteName = ""
        $lcDescrip      = "ANULACION DE FACTURA "    
        #$lcGuiaRemision ="NRO.CUENTA BBVA BANCO CONTINENTAL : 0244-0100023293"
        $lcGuiaRemision =""
        $lcPlaca =""
        $lcDocument_serial_id = $lg_serial_id2
        #$lcAutorizacion =""
        #$lcAutorizacion1=""

          $lcPercentIgv  =18000   
          $lcAutorizacion="Autorizado mediante Resolucion de Intendencia Nro.034-005-0004185/SUNAT del 26/10/2015 "
        $lcCuentas=" El pago del documento sera necesariamente efectuado mediante deposito en cualquiera de las siguientes cuentas bancarias:  
Banco SCOTIABANK Cuenta Corriente soles : 000-2681110 CCI : 009-702-000002681110-29
BBVA CONTINENTAL Cuenta Corriente soles : 0011-0244-01-00023293 CCI : 011 244 000100023293 12
Banco de CREDITO Cuenta Corriente soles : 191-2231128-0-45 CCI : 00219100223112804551"

          $lcScop1       =""   
          $lcScop2       =""
          $lcCantScop1   =""
          $lcCantScop2   =""  
          $lcAutorizacion1=$lcAutorizacion +$lcCuentas
  end

  # GET /notacredits/new
  def new
    @notacredit = Notacredit.new
    @notas = Notum.all 
    @customers = Client.all.order(:vrazon2)
    @notacredit[:code] = "#{generate_guid()}"
    @notacredit[:processed] = false
    @edit =true 


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

        files_to_clean = Dir.glob("*.xml") + Dir.glob("./app/pdf_output/*.pdf") + Dir.glob("*.zip")
        files_to_clean.each do |file|
          File.delete(file)
        end 

      # Group 1
        credit_note_data = { issue_date: Date.new($aa,$mm,$dd), id: $lcNumeroNota, customer: {legal_name:$lcLegalName , ruc:$lcRuc },
                             billing_reference: {id: $lcBillingReference, document_type_code: "01"},
                             discrepancy_response: {reference_id: $lcBillingReference, response_code: "09", description: $lcDescrip},
                             lines: [{id: "1", item: {id: "05", description: "DIESEL B5 S-50"}, quantity: $lcCantidad, unit: 'GLL', 
                                  price: {value: $lcPrecioSIgv}, pricing_reference: $lcPrecioCigv, tax_totals: [{amount: $lcIgv, type: :igv, code: "10"}], line_extension_amount:$lcVVenta }],
                             additional_monetary_totals: [{id: "1001", payable_amount: $lcVVenta}], tax_totals: [{amount: $lcIgv, type: :igv}], legal_monetary_total: $lcTotal}

        SUNAT.environment = :production

        files_to_clean = Dir.glob("*.xml") + Dir.glob("./pdf_output/*.pdf") + Dir.glob("*.zip")
        files_to_clean.each do |file|
          File.delete(file)
        end

        credit_note = SUNAT::CreditNote.new(credit_note_data)
        
        if credit_note.valid?
          begin
          credit_note.deliver!    
          rescue Savon::SOAPFault => e
              puts "Error generating document for case : #{e}"              
              $aviso ="Error generating document for case : #{e}"              
          end

          File::open("credit_note.xml", "w") { |file| file.write(credit_note.to_xml) }

          credit_note.to_pdf
        else
          puts "Invalid document, ignoring output: #{credit_note.errors.messages}"
          $aviso = "Invalid document, ignoring output: #{credit_note.errors.messages}"
        end

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
        
        credit_note_data = { issue_date: Date.new($aa,$mm,$dd), id: $lcNumeroNota, customer: {legal_name:$lcLegalName , ruc:$lcRuc },
                             billing_reference: {id: $lcBillingReference, document_type_code: "01"},
                             discrepancy_response: {reference_id: $lcBillingReference, response_code: "09", description: $lcDescrip},
                             lines: [{id: "1", item: {id: "05", description: "DIESEL B5 S-50"}, quantity: $lcCantidad, unit: 'GLL', 
                                  price: {value: $lcPrecioSIgv}, pricing_reference: $lcPrecioCigv, tax_totals: [{amount: $lcIgv, type: :igv, code: "10"}], line_extension_amount:$lcVVenta }],
                             additional_monetary_totals: [{id: "1001", payable_amount: $lcVVenta}], tax_totals: [{amount: $lcIgv, type: :igv}], legal_monetary_total: $lcTotal}

        

        credit_note = SUNAT::CreditNote.new(credit_note_data)
        
        if credit_note.valid?              
        
           credit_note.to_pdf

           $lcFileName1=File.expand_path('../../../', __FILE__)+ "/"+$lcFileName
                
          send_file("#{$lcFileName1}", :type => 'application/pdf', :disposition => 'inline')


        else

          puts "Invalid document, ignoring output: #{credit_note.errors.messages}"
          $aviso = "Invalid document, ignoring output: #{credit_note.errors.messages}"

        end

        

        $lcGuiaRemision =""      
        @@document_serial_id =""
        $lg_serial_id=""

    end 

        
    def sendmail      

        
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

     if $lcTd == 1   

       credit_note_data = { issue_date: Date.new($aa,$mm,$dd), id: $lcNumeroNota, customer: {legal_name:$lcLegalName , ruc:$lcRuc },
                             billing_reference: {id: $lcBillingReference, document_type_code: "01"},
                             discrepancy_response: {reference_id: $lcBillingReference, response_code: "09", description: $lcDescrip},
                             lines: [{id: "1", item: {id: "05", description: $lcDescrip2}, quantity: $lcCantidad, unit: 'GLL', 
                                  price: {value: $lcPrecioSIgv}, pricing_reference: $lcPrecioCigv, tax_totals: [{amount: $lcIgv, type: :igv, code: "10"}], line_extension_amount:$lcVVenta }],
                             additional_monetary_totals: [{id: "1001", payable_amount: $lcVVenta}], tax_totals: [{amount: $lcIgv, type: :igv}], legal_monetary_total: $lcTotal}
        
        credit_note = SUNAT::CreditNote.new(credit_note_data)
        
        if credit_note.valid?          
          credit_note.to_pdf
          File::open("credit_note.xml", "w") { |file| file.write(credit_note.to_xml) }

          
          $lcFileName1 = File.expand_path('../../../', __FILE__)+ "/"+$lcFileName        
            
          $lcFile2     = File.expand_path('../../../', __FILE__)+"/credit_note.xml"

          #$lcFile2     = File.expand_path('../../../../', __FILE__)+"/sunat-ruby9/credit_note.xml"        

          ActionCorreo.bienvenido_email(@invoice).deliver    
          @mailing = Mailing.new(:td =>$lcTd, :serie => 'FF01', :numero => $lcDocument_serial_id, :ruc=>$lcRuc, :flag1 => '1')
          @mailing.save      
        else
          $aviso =  "Invalid document, ignoring output: #{credit_note.errors.messages}"
        end
                
      else

          debit_note_data = { issue_date: Date.new($aa,$mm,$dd), id: $lcNumeroNota, customer: {legal_name:$lcLegalName , ruc:$lcRuc },
                     billing_reference: {id: $lcBillingReference, document_type_code: "01"},
                     discrepancy_response: {reference_id: $lcBillingReference, response_code: "02", description: $lcDescrip},
                     lines: [{id: "1", item: {id: "05", description: $lcDescrip2}, quantity: $lcCantidad, unit: 'GLL', 
                          price: {value: $lcPrecioSIgv}, pricing_reference: $lcPrecioCigv, tax_totals: [{amount: $lcIgv, type: :igv, code: "10"}], line_extension_amount:$lcVVenta }],
                     additional_monetary_totals: [{id: "1001", payable_amount: $lcVVenta}], tax_totals: [{amount: $lcIgv, type: :igv}], legal_monetary_total: $lcTotal}

          debit_note = SUNAT::DebitNote.new(debit_note_data)
          

        if debit_note.valid?
            debit_note.to_pdf
            File::open("debit_note.xml", "w") { |file| file.write(debit_note.to_xml) }
            $lcFileName1 = File.expand_path('../../../', __FILE__)+ "/"+$lcFileName
              $lcFile2     = File.expand_path('../../../', __FILE__)+"/debit_note.xml"

            ActionCorreo.bienvenido_email(@invoice).deliver    
            @mailing = Mailing.new(:td =>$lcTd, :serie => 'FF01', :numero => $lcDocument_serial_id, :ruc=>$lcRuc, :flag1 => '1')
            @mailing.save      

        else
          
          $aviso = "Invalid document, ignoring output: #{debit_note.errors.messages}"          
        end



      end 

        $lcGuiaRemision =""            
    end



  # GET /notacredits/1/edit
  def edit
    @notacredit = Notacredit.find(params[:id])
    @notas = Notum.all 
    @edit=true  
    @customers = Client.all.order(:vrazon2)

  end

  # POST /notacredits
  # POST /notacredits.json
  def create
    @notacredit = Notacredit.new(notacredit_params)

   @customers = Client.all.order(:vrazon2)
    @quantity = params[:notacredit][:quantity] 
    @precio = params[:notacredit][:price] 
    
    @notacredit[:subtotal] = @quantity.to_f  * @precio.to_f
    @notacredit[:total] = @notacredit[:subtotal] * 1.18
    @notacredit[:tax]  = @notacredit[:total] - @notacredit[:subtotal]
   

    

    respond_to do |format|
      if @notacredit.save
        format.html { redirect_to @notacredit, notice: 'Notacredit was successfully created.' }
        format.json { render :show, status: :created, location: @notacredit }
      else
        format.html { render :new }
        format.json { render json: @notacredit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notacredits/1
  # PATCH/PUT /notacredits/1.json
  def update
      @quantity = params[:notacredit][:quantity] 
    @precio = params[:notacredit][:price] 
    @notacredit[:subtotal] = @quantity.to_f  * @precio.to_f
   @notacredit[:total] = @notacredit[:subtotal] * 1.18
   @notacredit[:tax]  = @notacredit[:total] - @notacredit[:subtotal]
   
  
    
    respond_to do |format|
      if @notacredit.update(notacredit_params)
        format.html { redirect_to @notacredit, notice: 'Notacredit was successfully updated.' }
        format.json { render :show, status: :ok, location: @notacredit }
      else
        format.html { render :edit }
        format.json { render json: @notacredit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notacredits/1
  # DELETE /notacredits/1.json
  def destroy
    @notacredit.destroy
    respond_to do |format|
      format.html { redirect_to notacredits_url, notice: 'Notacredit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notacredit
      @notacredit = Notacredit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notacredit_params
      params.require(:notacredit).permit(:fecha, :code, :nota_id, :motivo, :subtotal, :tax, :total, :moneda_id, :mod_factura, :mod_tipo, :processed, :tipo, :description, :client_id,:price,:quantity,:notum_id,:nombre)
    end
end
