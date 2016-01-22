defmodule Opencov.BadgeManager do
  use Opencov.Web, :manager

  alias Opencov.Badge
  alias Opencov.BadgeCreator
  
  import Opencov.Badge


  def get_or_create(project, format \\ default_format) do
    case find(project.id, format) do
      nil -> create(project, format)
      badge -> return_or_update(project, badge)
    end
  end

  defp return_or_update(project, badge) do
    if project.current_coverage == badge.coverage,
      do: {:ok, badge},
      else: update(project, badge)
  end

  defp make(project, format, cb) do
    case BadgeCreator.make_badge(project.current_coverage, format: format) do
      {:ok, _format, image} -> {:ok, cb.(image)}
      {:error, e} -> {:error, e}
    end
  end

  defp create(project, format) do
    make project, format, fn image ->
      params = %{image: image, format: to_string(format), coverage: project.current_coverage}
      Ecto.build_assoc(project, :badge)
      |> Badge.changeset(params)
      |> Repo.insert!
    end
  end

  defp find(project, format),
    do: Badge |> for_project(project) |> with_format(format) |> Repo.one

  defp update(project, badge) do
    make project, badge.format, fn image ->
      Badge.changeset(badge, %{coverage: project.current_coverage, image: image})
      |> Repo.update!
    end
  end
end
