set export := true

package_name := "Sample"
nuget_source := "https://api.nuget.org/v3/index.json"
nuget_api_key := env_var_or_default("NUGET_API_KEY", "None")
nuget_delete_key := env_var_or_default("NUGET_DELETE_KEY", "None")

source := justfile_directory() + "/src"
tests := justfile_directory() + "/tests"
release := `git tag -l --sort=-creatordate | head -n 1`
replace := if os() == "linux" { "sed -i" } else { "sed -i '' -e" }

# For lazy people
alias b := build
alias t := test
alias bnix := build-nix
alias gd := gen-deps

# Lists all availiable targets
default:
    @echo "PROJECT: {{package_name}} - RELEASE: {{release}}"
    just --list

# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/dotnet.section.md#generating-and-updating-nuget-dependencies-generating-and-updating-nuget-dependencies
# Generates nix dependencies for deps.nix
gen-deps:
    dotnet restore --packages out
    nix run nixpkgs#nuget-to-nix -- out > deps.nix

# Builds the project
build:
    dotnet restore
    dotnet build

# Builds the project (with Nix)
build-nix:
    nix build

# Runs testing suite
test:
    ls {{tests}}/*.Tests/*.fsproj | xargs -L1 dotnet test --logger:trx

# Packages current tag as a .Net release
pack:
	@echo "PACKING RELEASE: {{release}}"
	rm -f */bin/Release/*.nupkg
	dotnet pack -c Release /p:Version=$(echo {{release}} | sed 's/v//g')

# Pushes release to NUGET
[confirm("Are you sure you want to push the current release?")]
push:
	@echo "Pushing release '{{release}}' to {{nuget_source}}"
	dotnet nuget push */bin/Release/*.nupkg -k "{{nuget_api_key}}" -s {{nuget_source}} --skip-duplicate

# Deletes a release
[confirm("Are you sure you want to delete the current release?")]
delete:
	@echo "Removing release '{{release}}' from {{nuget_source}}"
	dotnet nuget delete {{package_name}} $(echo {{release}} | sed 's/v//g') \
		-k "{{nuget_delete_key}}" \
		-s {{nuget_source}} \
		--non-interactive
