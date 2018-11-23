defmodule Dml.MarketplaceTest do
  use Dml.DataCase

  alias Dml.Marketplace

  describe "bounties" do
    alias Dml.Marketplace.Bounty

    @valid_attrs params_for(:bounty)
    @update_attrs params_for(:bounty) |> Map.take([:name, :description])
    @invalid_attrs params_for(:bounty, name: "")

    test "list_bounties/0 returns all bounties" do
      bounty = insert(:bounty)
      bounties = Marketplace.list_bounties()

      assert Enum.count(bounties) == 1
      assert has_element_by_id(bounties, %{id: bounty.id})
    end

    test "list_open_bounties/0 returns only open bounties" do
      bounty = insert(:bounty, state: "open")
      _bounty = insert(:bounty, state: "closed")
      bounties = Marketplace.list_open_bounties()

      assert Enum.count(bounties) == 1
      assert has_element_by_id(bounties, %{id: bounty.id})
    end

    test "list_bounties_from_user/1 returns user bounties" do
      bounty = insert(:bounty)
      _other_bounty = insert(:bounty)
      bounties = Marketplace.list_bounties_from_user(bounty.owner)

      assert Enum.count(bounties) == 1
      assert has_element_by_id(bounties, %{id: bounty.id})
    end

    test "get_bounty!/1 returns the bounty with given id" do
      bounty = insert(:bounty)

      assert Marketplace.get_bounty!(bounty.id).id == bounty.id
    end

    test "create_bounty/1 with valid data creates a bounty" do
      user = insert(:user)
      assert {:ok, %Bounty{} = bounty} = Marketplace.create_bounty(user.id, @valid_attrs)
      assert bounty.name == @valid_attrs[:name]
      assert bounty.owner_id == user.id
    end

    test "create_bounty/1 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, changeset} = Marketplace.create_bounty(user, @invalid_attrs)
      assert "can't be blank" in errors_on(changeset).name
    end

    test "update_bounty/2 with valid data (only name) updates the bounty" do
      bounty = insert(:bounty)
      assert {:ok, %Bounty{} = bounty} = Marketplace.update_bounty(bounty, @update_attrs)
      assert bounty.name == @update_attrs[:name]
    end

    test "update_bounty/2 with invalid data returns error changeset" do
      bounty = insert(:bounty)
      assert {:error, %Ecto.Changeset{}} = Marketplace.update_bounty(bounty, @invalid_attrs)
    end

    test "update_bounty_state/2 with valid state updates the bounty" do
      bounty = insert(:bounty)
      assert bounty.state == "pending"
      assert {:ok, %Bounty{} = bounty} = Marketplace.update_bounty_state(bounty, "open")

      bounty = Marketplace.get_bounty!(bounty.id)
      assert bounty.state == "open"
    end
  end

  describe "enrollments" do
    alias Dml.Marketplace.Enrollment

    setup do
      %{bounty: insert(:bounty)}
    end

    test "list_enrollments/1 returns all enrollments", %{bounty: bounty} do
      enrollment = insert(:enrollment, bounty: bounty)
      _other_enrollment = insert(:enrollment)
      enrollments = Marketplace.list_enrollments(bounty)

      assert Enum.count(enrollments) == 1
      assert has_element_by_id(enrollments, %{id: enrollment.id})
    end

    test "get_enrollment!/1 returns the enrollment with given id" do
      enrollment = insert(:enrollment)

      assert Marketplace.get_enrollment!(enrollment.id).id == enrollment.id
    end

    test "create_enrollment/1 with valid data creates a enrollment", %{bounty: bounty} do
      user = insert(:user)

      assert {:ok, %Enrollment{} = enrollment} = Marketplace.create_enrollment(user.id, bounty.id)
      assert enrollment.user_id == user.id
      assert enrollment.bounty_id == bounty.id
      assert enrollment.state == "pending"
      assert enrollment.rewarded == false
    end

    test "create_enrollment/1 with invalid data returns error changeset", %{bounty: bounty} do
      assert {:error, changeset} = Marketplace.create_enrollment(nil, bounty.id)
      assert "can't be blank" in errors_on(changeset).user_id
    end
  end

  describe "algorithms" do
    alias Dml.Marketplace.Algorithm

    @valid_attrs params_for(:algorithm)
    @update_attrs params_for(:algorithm) |> Map.take([:title, :description])
    @invalid_attrs params_for(:algorithm, title: "")

    test "list_algorithms/0 returns all algorithms" do
      algorithm = insert(:algorithm)
      algorithms = Marketplace.list_algorithms()

      assert Enum.count(algorithms) == 1
      assert has_element_by_id(algorithms, %{id: algorithm.id})
    end

    test "list_algorithms_from_user/1 returns user algorithms" do
      algorithm = insert(:algorithm)
      _other_algorithm = insert(:algorithm)
      algorithms = Marketplace.list_algorithms_from_user(algorithm.user)

      assert Enum.count(algorithms) == 1
      assert has_element_by_id(algorithms, %{id: algorithm.id})
    end

    test "list_approved_algorithms/1 returns only approved algorithms" do
      algorithm = insert(:algorithm, state: "approved")
      _other_algorithm = insert(:algorithm)
      algorithms = Marketplace.list_approved_algorithms()

      assert Enum.count(algorithms) == 1
      assert has_element_by_id(algorithms, %{id: algorithm.id})
    end

    test "get_algorithm!/1 returns the algorithm with given id" do
      algorithm = insert(:algorithm)

      assert Marketplace.get_algorithm!(algorithm.id).id == algorithm.id
    end

    test "create_algorithm/1 with valid data creates an algorithm" do
      user = insert(:user)
      assert {:ok, %Algorithm{} = algorithm} = Marketplace.create_algorithm(user.id, @valid_attrs)
      assert algorithm.title == @valid_attrs[:title]
      assert algorithm.description == @valid_attrs[:description]
      assert algorithm.user_id == user.id
      assert algorithm.bounty_id == nil
      assert algorithm.enrollment_id == nil
    end

    test "create_algorithm/1 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, changeset} = Marketplace.create_algorithm(user, @invalid_attrs)
      assert "can't be blank" in errors_on(changeset).title
    end

    test "update_algorithm/2 with valid data (only title) updates the algorithm" do
      algorithm = insert(:algorithm)
      assert {:ok, %Algorithm{} = algorithm} = Marketplace.update_algorithm(algorithm, @update_attrs)
      assert algorithm.title == @update_attrs[:title]
    end

    test "update_algorithm/2 with bounty ID updates the algorithm" do
      algorithm = insert(:algorithm)
      bounty = insert(:bounty)
      user = insert(:user)
      {:ok, enrollment} = Marketplace.create_enrollment(user.id, bounty.id)

      attrs = %{bounty_id: bounty.id, enrollment_id: enrollment.id}

      assert {:ok, %Algorithm{} = algorithm} = Marketplace.update_algorithm(algorithm, attrs)

      assert algorithm.bounty_id == bounty.id
      assert algorithm.enrollment_id == enrollment.id
    end

    test "update_algorithm/2 with attachment, saves the file" do
      algorithm = insert(:algorithm)
      file = %Plug.Upload{filename: "algorithm.txt", path: Path.join(File.cwd!(), "test/fixtures/algorithm.txt")}

      assert {:ok, %Algorithm{} = algorithm} = Marketplace.update_algorithm(algorithm, %{file: file})
      assert %{file_name: "algorithm.txt"} = algorithm.file

      url = DmlWeb.Algorithm.url({algorithm.file, algorithm}, :original)
      assert Regex.match?(~r{/uploads/algorithms/[a-f\d-]+/[A-F\d]+_original.txt\?v=\d+}, url)
    end

    test "update_algorithm/2 with tags updates the algorithm" do
      algorithm = insert(:algorithm)
      assert {:ok, %Algorithm{} = algorithm} = Marketplace.update_algorithm(algorithm, %{tags: ["hi", "hello"]})
      assert Enum.member?(algorithm.tags, "hi")
      assert Enum.member?(algorithm.tags, "hello")
    end

    test "update_algorithm/2 with invalid data returns error changeset" do
      algorithm = insert(:algorithm)
      assert {:error, %Ecto.Changeset{}} = Marketplace.update_algorithm(algorithm, @invalid_attrs)
    end
  end
end
