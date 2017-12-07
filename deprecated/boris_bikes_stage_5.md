## Stage 5: Giving Docking Stations Limited Capacities

***As with all Makers Academy materials, there may be subtle errors in the following materials.  Please try to approach those as challenges on which to polish your debugging skills - pull requests always welcome.***

At any point in the development process there is a judgement call to make about whether to refactor or to start working on new features.  There are no hard-and-fast rules.  You may be particularly offended by design 'smells' coming from your code.  Or, you may feel that these will be resolved naturally as part of the process of implementing the next user story.  Spend a little time reflecting on the code you have so far.  It should be pretty lean :-) Time for another user story:

```
As a maintainer of the system,
So that I can control the distribution of bikes,
I'd like docking stations not to accept more bikes than their capacity.
```

This is a great user story to pick next as it introduces an entirely new concept to our domain: *capacity*.

Does the client want docking stations that store just 1 bike or should they store 20, 50, 100?  This would be a good time to check with the client what the storage capacity requirements are for docking stations.  Perhaps they weren't discussed in the initial client meeting.  

In the meantime, let's assume a capacity of 1.  It's a fairly unreasonable assumption; but in order to do the least amount of work to support the user story, let's create a feature test that raises an error when trying to dock a bike into a station that already has a bike.  Remember that that this involves writing out the code that we would like to be able to run in irb:

```
$ irb
2.1.5 :001 > require './lib/docking_station'
 => true
2.1.5 :002 > docking_station = DockingStation.new
 => #<DockingStation:0x007fe022230258 ...>
2.1.5 :003 > docking_station.dock Bike.new
 => #<Bike:0x007f8d7424cee0>
2.1.5 :004 > docking_station.dock Bike.new
RuntimeError: DockingStation
	.... stack trace omitted ....
```

Run this in IRB to ensure that it currently does not raise an error (because, for a capacity of 1, _that's a failure_ right?) and then drop into a unit test:

```ruby
require 'docking_station'

describe DockingStation do
  # other tests omitted for brevity

  describe 'dock' do
    it 'raises an error when full' do
      subject.dock Bike.new
      expect { subject.dock Bike.new }.to raise_error 'Docking station full'
    end
  end
end
```

Let's make our failing unit test pass:

```ruby
class DockingStation
  def dock(bike)
    fail 'Docking station full' if @bike
    @bike = bike
  end

  def release_bike
    fail 'No bikes available' unless @bike
    @bike
  end
end
```

**Once passing please ensure that you run all your manual feature tests in IRB.  Is everything as we expect?  Are all parts of the system still behaving correctly?**

We just finish getting this working and in comes an email from our client.  Docking stations should have a default capacity of 20, but sometimes they have a capacity of 30 or 40.  Hearing this, we refrain from leaping in to the code base, or even the tests, but update our user stories and domain model appropriately.

```
As a system maintainer,
So that I can plan the distribution of bikes,
I want a docking station to have a default capacity of 20 bikes.

As a system maintainer,
So that busy areas can be served more effectively,
I want to be able to specify a larger capacity when necessary.
```

We have some options now.  You might find yourself thinking about what data structure we use to enable docking stations to contain bikes. We might imagine a series of instance variables in our docking station class; e.g. `@bike0`, `@bike1`, `@bike2`; or an array instance variable, e.g. `@bikes = []`; or even a hash such as `@bikes = {}`.  Ideally, we should choose the least complex data structure that supports what we need to pass our tests.  It is often tempting to think, ooh, yes, bikes could have ids and so we could use a hash and then we could grab bike by id, e.g. `{'BIKEID007': <#Bike>}` etc., but we are not yet working on any user stories that require bikes to have ids.  You will make faster progress if you keep your object models and data structures as simple as possible.  In this case the array seems like a good choice for keeping track of the maximum 20 bikes we need to be able to store in our docking station.  And we might be tempted to leap in and start hacking up our application code, adding an array and so on, but it is a much better practice to hold off; deciding on the actual data structure or object model until the last reasonable moment.  Far better to allow the user stories to drive us to create tests that specify how our system operates.  Get that nailed down and then it should become clear which is the best choice of data structure or object model.

So let's adjust our existing manual feature test to support this new user story:

```
$ irb
2.1.5 :001 > require './lib/docking_station'
 => true
2.1.5 :002 > docking_station = DockingStation.new
 => #<DockingStation:0x007fe022230258 ...>
2.1.5 :003 > 20.times { docking_station.dock Bike.new }
 => #<Bike:0x007f8d7424cee0>
2.1.5 :004 > docking_station.dock Bike.new
RuntimeError: DockingStation
	.... stack trace omitted ....
```

Naturally this won't work as expected.  Note that we haven't updated our unit tests yet.  One step at a time.  It's a good idea to check that the system is giving you the behaviour you expect before each and every change.  Let's now update our docking_station_spec.rb unit test:

```ruby
require 'docking_station'

describe DockingStation do
  # other tests omitted for brevity

  describe 'dock' do
    it 'raises an error when full' do
      20.times { subject.dock Bike.new }
      expect { subject.dock Bike.new }.to raise_error 'Docking station full'
    end
  end
end
```

We should now have a failure from our unit test to match the way our manual feature test fails.  That means it's time to start changing our application code.  An array seems like a good data structure for holding the bikes - let's try that out:

```ruby
class DockingStation
  def initialize
    @bikes = []
  end

  def release_bike
    fail 'No bikes available' if @bikes.empty?
    @bikes.pop
  end

  def dock(bike)
    fail 'Docking station full' if @bikes.count >= 20
    @bikes << bike
  end
end
```

You should have run `rspec` without even thinking about it.  Everything green?  Just run your manual feature test checks in IRB and then you'll be ready to commit your code to GitHub right? Naturally you've been regularly backing up your code to GitHub all along :-) Just in case here's a reminder: **You should commit on each RED - GREEN - REFACTOR cycle.**  How much code do you want to risk losing in a computer crash?

Speaking of RED - GREEN - REFACTOR, we haven't done any refactoring recently, so now would be a good time to look for opportunities.

This is a great opportunity to introduce the Single Responsibility Principle (SRP).  Everything in code should have a _single recognizable responsibility_.  Our `DockingStation` class is responsible for docking and releasing bikes.  While you might argue that that's _two_ responsibilities(!), they are inextricably dependent on one-another, so it's OK.  But we do separate those responsibilities into individual methods.  Similarly, each method should have a _single responsibility_.  In our code, the `dock` method is responsible for handling the docking of a bike:
```
fail 'Docking station full' if @bikes.count >= 20
@bikes << bike
```
**and** defining the rule for capacity:
```
@bikes.count >= 20
```
This is a bad thing for 2 reasons.  Firstly, because it breaks the single responsibility principle, and secondly because it necessitates an additional cognitive step when reading the code.  As a reader, I am forced to infer that `@bikes.count >= 20` corresonds to the docking station being full.

Let's fix this and improve the readability of our code by introducing private helper methods `empty?` and `full?`. In general we don't write unit tests for private methods. Why do you think that is? Discuss this with your pair partner.

```ruby
class DockingStation
  def initialize
    @bikes = []
  end

  def release_bike
    fail 'No bikes available' if empty?
    @bikes.pop
  end

  def dock(bike)
    fail 'Docking station full' if full?
    @bikes << bike
  end

  private

  def full?
    @bikes.count >= 20
  end

  def empty?
    @bikes.empty?
  end
end
```

Having made the above refactoring, you will of course want to immediately run RSpec again to ensure that we haven't accidentally introduced any errors.  And of course you'll want to manually test that everything still works in IRB.  Getting a little tired of manual testing in IRB?  We'll introduce you to some ways to automate your feature tests soon, but it is really really really important that you get comfortable and familiar with experimenting with your code in IRB.

Any more refactoring? We really should also deal with the 'magic number' `20`.  Magic numbers are a common source of bugs in computer programs.  They occur wherever a numeric literal (e.g `20`) is used in code and is related to a domain concept; in this case, the default capacity of a docking station.  In a large and complex program, if we were to see the literal `20` all over the place, it would not be obvious, without reading the context in which it is used, whether it is a reference to capacity or some other domain concept that happens to also be 20.  What if the default capacity changes?

To deal with this, we *encapsulate* the literal in a *constant* then use this constant everywhere else:

```ruby
class DockingStation
  DEFAULT_CAPACITY = 20

  # other code omitted for brevity

  def full?
    bikes.count >= DEFAULT_CAPACITY
  end
end
```

This is a good start, however is there anywhere else where we use the magic number `20`?  How about in our tests?  Here's a handy blog post on the subject of [testing with magic numbers](http://blog.silvabox.com/testing-with-magic-numbers/).  Which approach should we use here?  Also this raises the question of whether a docking station is full if the count of bikes exceeds the default capacity; or the specific capacity definied for that station?  

It feels like we need a `capacity` attribute for our docking station.  But we can't introduce one without a unit test:

```ruby
describe DockingStation do
  # other tests omitted for brevity

  it 'has a default capacity' do
    expect(subject.capacity).to eq DockingStation::DEFAULT_CAPACITY
  end
end
```

See if you can make this test pass.  Hint: use `attr_reader` to create the `capacity` method and use `initialize` to set its initial value.  Don't forget to change the `full?` method to use our new `capacity`.

Actually, since docking station is already taking care of this, we can use the `capacity` that's already defined:

```ruby
describe DockingStation do
  describe 'dock' do
    it 'raises an error when full' do
      subject.capacity.times { subject.dock Bike.new }
      expect { subject.dock Bike.new }.to raise_error 'Docking station full'
    end
  end
end
```

We might also use a _private_ `attr_reader` to have all our references to the `@bikes` instance variable go through a single interface:

```ruby
class DockingStation
  DEFAULT_CAPACITY = 20

  attr_reader :capacity

  def initialize
    @bikes = []
    @capacity = DEFAULT_CAPACITY
  end

  def dock(bike)
    fail 'Docking station full' if full?
    bikes << bike
  end

  def release_bike
    fail 'No bikes available' if empty?
    bikes.pop
  end

  private

  attr_reader :bikes

  def full?
    bikes.count >= capacity
  end

  def empty?
    bikes.empty?
  end
end
```

We prefer to reference our instance variable within our class via getter methods in order to DRY out the '@' symbols, and so also that if we need to make some consistent initialization or change to our instance variable, then we can do it in one place, rather than having to update a series of scattered references to instance variables throughout the class.


:running_shirt_with_sash: ATHLETIC WAYPOINT - try re-creating the code so far from scratch without looking at the tutorial.

We have a remaining user story relating to capacity:

```
As a system maintainer,
So that busy areas can be served more effectively,
I want to be able to specify a larger capacity when necessary.
```

Have a go in your pair at implementing the necessary functionality through appropriate use of feature and unit tests.

Think about the sequence of steps you might use, e.g.

1. think about the user story
2. create a corresponding manual feature test for irb
3. create a minimal matching unit test or tests
4. see relation between the way the feature does not work and the unit test failures
5. create the functionality in the application
6. see the unit test pass and the feature test move to next fail
7. loop back to step 3 until feature test passes

The key question is how will a new capacity be passed to the docking station. And can docking stations change their capacity over time?  Hmm, another question for the client, we can send another email, but in the mean time what should we assume?  That docking station capacities can change over time, or that they are fixed once?  Depending on what we assume, we might choose a different route to pass the new capacity to a docking station.  If fixed once then we might well pass through an initialize method like so:

```
$ irb
2.1.5 :001 > require './lib/docking_station'
 => true
2.1.5 :002 > docking_station = DockingStation.new 50
  => #<DockingStation:0x007fa37eba3be0 @bikes=[], @capacity=50>
```

which would rely on an initialize method in our class

```ruby
class DockingStation
  def initialize(capacity)
    @capacity = capacity
  end
end
```

however if docking station capacities can vary over their lifetime then perhaps we could create a writeable attribute like so:

```ruby
class DockingStation
  attr_accessor :capacity
end
```

so that we can update the docking station capacity at will:

```
$ irb
2.1.5 :001 > require './lib/docking_station'
 => true
2.1.5 :002 > docking_station = DockingStation.new
=> #<DockingStation:0x007fa37eb90338 @bikes=[], @capacity=20>
2.1.5 :003 > docking_station.capacity = 25
=> #<DockingStation:0x007fa37eb90338 @bikes=[], @capacity=25>
2.1.5 :004 > docking_station.capacity = 55
=> #<DockingStation:0x007fa37eb90338 @bikes=[], @capacity=55>
```

In the absence of input from the client which is the best place to start?  You decide.  If you go for the former consider how you'll handle the case when no capacity is initially set [Hint: research Ruby's ability to set default values for arguments on any method].

Then time to move on to [Stage 6](boris_bikes_stage_6.md)!
