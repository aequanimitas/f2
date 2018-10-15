defmodule F2Test do
  use ExUnit.Case
  doctest F2

  describe "handle_msg/3, :allocate -" do
    test "empty pre-allocated frequencies" do
      assert {{[], []}, {:error, :all_allocated}} =
        nil
        |> F2.handle_msg(:allocate, {[], []})
    end
    
    test "has frequencies" do
      parent = self()
      assert {{[], [{^parent, 10}]}, {:ok, 10}} =
        parent 
        |> F2.handle_msg(:allocate, {[10], []})
    end

    test "linking" do
      {:true, pid} = F2.start()
      assert {:ok, 10} = F2.allocate()
      assert true = self() in Process.info(pid)[:links]
      assert true = pid in Process.info(self())[:links]
      Process.exit(pid, :normal)
    end
  end

  describe "handle_msg/3, :deallocate:" do
    test "empty allocated" do
      assert {{[], []}, {:error, :nothing_allocated}} =
        nil
        |> F2.handle_msg({:deallocate, 10}, {[], []})
    end

    test "deallocates if owner" do
      parent = self()
      assert {{[10], []}, {:ok, :deallocate}} =
        parent
        |> F2.handle_msg({:deallocate, 10}, {[], [{parent, 10}]})
    end

    test "frequency borrower dies" do
    end
  end
end
