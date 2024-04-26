defmodule AshArchival.Resource.Info do
  use Spark.InfoGenerator, extension: AshArchival.Resource, sections: [:archive]
end
