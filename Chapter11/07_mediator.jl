module MediatorExample

# A Widget is the super type of all GUI widgets
abstract type Widget end

# TextField is one kind of widget
mutable struct TextField <: Widget
    id::Symbol
    value::String
end

# An app
Base.@kwdef struct App
    amount_field::TextField
    interest_rate_field::TextField
    interest_amount_field::TextField
end

# Extract numeric value from a text field
get_number(t::TextField) = parse(Float64, t.value)

# Update text field from a numeric value
function set_number!(t::TextField, x::Real)
    println("* ", t.id, " is being updated to ", x)
    t.value = string(x)
    return nothing
end

# This function is called for any field chnages.
# Normally, a GUI framework triggers this call automatically
# when a field is updated.
function on_change_event(widget::Widget)
    notify(app, widget)
end

# Factor out the logic of updating the interest amount
function update_interest_amount!(app::App)
    new_interest = get_number(app.amount_field) * get_number(app.interest_rate_field)/100
    set_number!(app.interest_amount_field, new_interest)
end

# Notify the mediator `app` about a change in the `widget`.
function notify(app::App, widget::Widget)
    if widget in (app.amount_field, app.interest_rate_field)
        update_interest_amount!(app)
    end
end

# Second way of implementing this mediator: setters
function set_amount!(app::App, amount::Real)
    set_number!(app.amount_field, amount)
    update_interest_amount!(app)
end

function set_interest_rate!(app::App, interest_rate::Real)
    set_number!(app.interest_rate_field, interest_rate)
    update_interest_amount!(app)
end

# Third way: event type
struct ChangeEvent end

function notify(app::App, ::ChangeEvent)
    update_interest_amount!(app)
end

function set_amount2!(app::App, amount::Real)
    set_number!(app.amount_field, amount)
    notify(app, ChangeEvent())
end

function set_interest_rate2!(app::App, interest_rate::Real)
    set_number!(app.interest_rate_field, interest_rate)
    notify(app, ChangeEvent())
end

# Create an app (the mediator) with some defualt values
const app = App(
    amount_field = TextField(:amount, "100.00"), 
    interest_rate_field = TextField(:interest_rate, "5"),
    interest_amount_field = TextField(:interest_amount, "5.00"))

# For testing purpose
function print_current_state()
    println("current amount = ", get_number(app.amount_field))
    println("current interest rate = ", get_number(app.interest_rate_field))
    println("current interest amount = ", get_number(app.interest_amount_field))
    println()
end

function test()
    # Show current state before testing
    print_current_state()

    # double principal amount from 100 to 200
    set_number!(app.amount_field, 200)
    on_change_event(app.amount_field)
    print_current_state()
end

function test_setters()
    # Show current state before testing
    print_current_state()

    # double principal amount from 200 to 400
    set_amount!(app, 400)
    print_current_state()
end    

function test_change_event()
    # Show current state before testing
    print_current_state()

    # halve principal amount from 400 to 200 again
    set_amount2!(app, 200)
    print_current_state()
end  

end # module

using .MediatorExample
MediatorExample.test()
MediatorExample.test_setters()
MediatorExample.test_change_event()

#= 
julia> MediatorExample.test()
current amount = 100.0
current interest rate = 5.0
current interest amount = 5.0

* amount is being updated to 200
* interest_amount is being updated to 10.0
current amount = 200.0
current interest rate = 5.0
current interest amount = 10.0
=#