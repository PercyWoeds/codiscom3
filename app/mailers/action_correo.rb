class ActionCorreo < ApplicationMailer
  	  default from: 'factura-electronica@hidrotransp.com'


	  def bienvenido_email(invoice)
		  @invoices=invoice 			
		   @url  = 'http://www.apple.com'
		  #attachments["Factura"] = File.read("#{$lcFileName1}")
		  #attachments['Factura'] = File.read($lcFileName1)
		  email_with_name = "Factura Enviada <factura-electronica@hidrotransp.com>"	
		  email_with_copy = "Administracion <zportal@hidrotransp.com>"	
		
		  attachments[$lcFileName] =  open($lcFileName1).read

		  attachments[$lcFilezip] =  open($lcFile2).read

		  mail(to: [$lcMail,$lcMail2,$lcMail3],cc:email_with_copy ,  bcc:email_with_name, subject: 'Factura Electrónica : '+$lcFileNameIni )


	  end
end
