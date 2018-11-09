~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  default_release: :default,
  default_environment: Mix.env()

environment :dev do
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: :"vtV1C<k%Omc;4F:hM/d9?lWAmxLuddpFOk/3?T=/dZ9%I[&jA9nqNDuDD9k_{F36")
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"Xa*|YHP]DccqRNvdMRAX{hP]=h`=2c4)Vz_3SoIch:B,gC%,.;mpiW~KPx@*;B&Z")
  set(vm_args: "rel/vm.args")
end

release :dml do
  set(version: current_version(:dml))
  set(applications: [:runtime_tools])
end
