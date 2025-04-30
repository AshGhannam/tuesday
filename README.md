# Tuesday
It is a project management application built to help explain concepts in the book _Domain Modeling with Ash Framework_. You can read more about the book and it [here](https://devcarrots.com/).


## Using IEx
For readers who are following along the code given in the book, we have included a `.iex.exs` file in this repo for better developer experience. This ensures that you do not have to import or set alias for commonly used modules in your IEx shell when running the code from the book. Below is the contents of the file:

```elixir
require Ash.Query

import Ash.Expr
alias Tuesday.{Auth, Projects, Workspace, Playground}
alias Tuesday.Auth.User
alias Tuesday.Projects.{Comment, Project, ProjectMember, Task, TaskAssignee}
alias Tuesday.Workspace.{Organization, OrganizationMember}
```

Feel free to tweak this file as per needs. 

## Setup
After you clone the repository, you may run the below command to setup the project:
```shell
mix setup
```
This will install dependencies, setup the database, and run the seed file which populates sample data.

If you want to reset the database without running the seed file, you could do so by using the below command:
```shell
mix ash.reset
```

If you decide to run the seed file after running the above command, you may run the below command:
```shell
mix run priv/repo/seeds.exs
```

## Buy the Book

We're happy to share this code repository with everyone, even if you haven't purchased the book.  
If you'd like to dive deeper and understand more about the Ash Framework, you can buy the book [here](https://devcarrots.com/).

## Figma prototype
Although the app has no UI, we've developed a low-fidelity Figma prototype illustrating Tuesday’s features, which you can view [here](https://www.figma.com/proto/6Glp8UzeFARFJzPS3MykdM/Tuesday-app).

## License

This project is a labor of love and is released under the MIT License.  
You're free to use it however you like—and we welcome contributions back to the community in your own way!