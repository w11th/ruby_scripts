require 'fox16'

include Fox

my_app = FXApp.new
main_window = FXMainWindow.new(my_app, 'TestApp')

my_button = FXButton.new(main_window, 'Click Me!')
my_button.connect(SEL_COMMAND) do
  my_button.text = "I've been clicked!"
end

my_app.create
main_window.show(PLACEMENT_SCREEN)
my_app.run
