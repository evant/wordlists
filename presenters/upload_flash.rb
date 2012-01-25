class UploadFlash
  include Haml::Helpers

  attr_reader :context

  def initialize(message)
    @message = messae
    @context = {}
    init_haml_helpers
  end

  def to_s
    case @message
    when :upload_sucess
      haml_tag 'p.flash' do
            
      end
        "You uploaded #{@context[:word_count]} words to <a href='#{url(
        =@word_count
        words to
        %a{href: url("/view/#{h_uri(@category)}")}= @category
    end
  end
end
