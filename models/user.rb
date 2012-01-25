class User
  include DataMapper::Resource

  property :id, Serial
  property :ip, String

  has n, :words, :through => Resource
  has n, :categories, :through => Resource

  def self.from_cookie_or_ip(cookies, ip)
    user = (cookies[:user] and get(cookies[:user].to_i)) || first_or_create(:ip => ip)
    cookies[:user] = user.id
    user
  end
end
