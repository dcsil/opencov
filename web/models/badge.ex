defmodule Opencov.Badge do
  use Opencov.Web, :model

  import Ecto.Query

  schema "badges" do
    field :image, :binary
    field :format, :string
    field :coverage, :float

    belongs_to :project, Opencov.Project

    timestamps
  end

  @required_fields ~w(image format project_id)
  @optional_fields ~w(coverage)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def for_project(query, %Opencov.Project{id: project_id}),
    do: for_project(query, project_id)
  def for_project(query, project_id) when is_integer(project_id),
    do: query |> where(project_id: ^project_id)

  def with_format(query, format) when is_atom(format),
    do: with_format(query, Atom.to_string(format))
  def with_format(query, format),
    do: query |> where(format: ^format)

  def default_format,
    do: Application.get_env(:opencov, :badge_format)
end
