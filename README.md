# integrated_vehicle_management_system

This project is an organization centric application which manages the various functions in an organization.
These functions include:
- Departments
- Vehicles
- Employees
- Fuel Orders
- Repair Orders
- Reports
- Fuel Shipmants
- Fuel Stations
- Repair Store
- Notifications
- Chat

It stores a list of all departments, Vehicles, Employees, Fuel Orders and all others for the organization.

It has three user roles:
- Super User
- Admin
- User

A super User has unlimited access to the application, a super user can be any employee in the organization.
An Admin in this context is a Repair Manager who has access to all the vehicles, repair orders, repair reports and Repair Store.
An admin also in this context is a Transport Manager who has access to all the vehicles, fuel orders, fuel stations, fuel shipments and fuel order reports.

A User is either a driver, mechanic or a fuel attendant.
A driver is allocated a vehicle and he or she is able to make fuel and repair orders which are then approved by the respective admin; repair manager or transport manager.
A mechanic gets notifications on approved repair orders and after completing the repair he or she is able to complete the order in the application
A fuel attendant also receives notifications on approved fuel orders and he or she is able to complete the order after dispensing the fuel.

This says that all employees receives different types of notifications according to their positions and user roles. Also, every order has a life cycle where its status is begins as "submitted" followed by
"approved" or declined followed by "completed".

The application uses the sign in with email and password firebase authentication along with one time code.
- 

- 
