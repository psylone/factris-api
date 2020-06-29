# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Contract.create!([
  {
    number: 'A10',
    active: true,
    start_date: '2019-01-01',
    end_date: '2019-09-30',
    fixed_fee: 0.02,
    days_included: 14,
    additional_fee: 0.001
  },
  {
    number: 'A10',
    active: true,
    start_date: '2020-01-01',
    fixed_fee: 0.0175,
    days_included: 14,
    additional_fee: 0.001
  },
  {
    number: 'B21',
    active: true,
    start_date: '2019-01-01',
    fixed_fee: 0.021,
    days_included: 14,
    additional_fee: 0.001
  }
])
