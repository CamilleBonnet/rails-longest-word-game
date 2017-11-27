Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "game", to: "game#begin"
  get "score", to: "game#score"
  root to: "game#begin"
end
