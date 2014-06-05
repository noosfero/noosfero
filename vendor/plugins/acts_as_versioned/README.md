## About ##
=====

acts_as_versioned is a gem for Rails 3.1 & 3.2 to enable easy versioning of models. As a versioned model is updated revisions are kept in a seperate table, providing a record of what changed.

## Getting Started ##
=====

In your Gemfile simply include:

    gem 'acts_as_versioned', :git => 'https://github.com/jwhitehorn/acts_as_versioned.git'
    
The next time you run `bundle install` you'll be all set to start using acts_as_versioned.  

## Usage ##
=====

#### Versioning a Model ####
By default acts_as_versioned is unobtrusive. You will need to explicitly state which models to version. To do so, add the line `acts_as_versioned` to your model, like so:

    class MyModel < ActiveRecord::Base
      acts_as_versioned
      #...
    end
    
Next we need to create a migration to setup our versioning tables:

    bundle exec rails generate migration AddVersioningToMyModel
    
Once that is completed, edit the generated migration. acts_as_versioned patches your model to add a `create_versioned_table` and `drop_versioned_table` method. A migration for `MyModel` (assuming MyModel already existed) might look like:

    class AddVersioningToMyModel < ActiveRecord::Migration
      def self.up
        MyModel.create_versioned_table
      end

      def self.down
        MyModel.drop_versioned_table
      end
    end

Execute your migration:
    
    bundle exec rake db:migrate
    
And you're finished! Without any addition work, `MyModel` is being versioned.

#### Excluding attributes from versioning  ####

Sometime you want to exclude an attribute of a model from being versioned. That can be accomplished with the `:except` paramter to `acts_as_versioned`:

    class MyMode < ActiveRecord::Base
      acts_as_versioned :except => :some_attr_i_dont_want_versioned
      
    end


#### Revisions ####

Recording a history of changes to a model is only useful if you can do something with that data. With acts_as_versioned there are several ways you can interact with a model's revisions.

##### Version Number #####
To determine what the current version number for a model is:

    model.version

The `version` attribute is available for both the actual model, and also any revisions of a model. Thusly, the following is valid:

    model.versions.last.version

##### Revisions List #####
As alluded to above, you can get an array of revisions of a model via the `versions` attribute:

    model.versions
    
The returned objects are of a type `MyModel::Version` where `MyModel` is the model you are working with. These objects have identical fields to `MyModel`. So, if `MyModel` had a `name` attribute, you could also say:

    model.versions.last.name

##### Reverting to a Revision #####
To revert a model to an older revision, simply call `revert_to` with the version number you desire to rever to:

    model.revert_to(version_number)

##### Saving Without Revisions #####
Occasionally you might need to save a model without necessary creating revisions. To do so, use the `save_without_revision` method:
    
    model.save_without_revision


#### Migrations ####
Adding a field to your model does not automatically add it to the versioning table. So, when you add new fields, be sure to add them to both:

    class AddNewFieldToMyModel < ActiveRecord::Migration
      def change
        add_column :my_models, :new_field_, :string
        add_column :my_model_versions, :new_field_, :string
      end
    end

#### Version Class ####
As has been stated, the versioned data is stored seperately from the main class. This also implies that `model.versions` returns an area of object of a class _other_ than `MyModel` (where `model` is an instance of `MyModel`, keeping with our working example). The instances returned are actually of type `MyModel::Version`. With this, comes the fact that any methods, associations, etc. defined on `MyModel` are not present on `MyModel::Version`.

While this sounds obvious, it can some times be unexpected. Especially when acts_as_versioned make it so easy to grab historical records from a live record. A common scenario where this can come up is associations.

Say `MyModel` belongs to `TheMan`. Also, assume that you want to find out where (in the past) a particular instance of `MyModel` was updated in regards to it's association to `TheMan`. You could write that as:  
    
    model.versions.keep_if { |m| m.the_man != current_man }.last
    
However, this will not work. This is because `MyModel::Version` does _not_ belong to `TheMan`. You could compare ids here, or you could patch `MyModel::Version` to belong to `TheMan` like:

    class MyModel
      acts_as_versioned
      belongs_to :the_men
      #some stuff
      
      class Version
        belongs_to :the_men
      end
    end