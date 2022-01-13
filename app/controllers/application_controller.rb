class ApplicationController < ActionController::API
    #cookieを使用
    include ActionController::Cookies
    #認可を行う
    include UserAuthenticateService

end
