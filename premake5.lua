workspace "Belegium_Matcher"
    startproject "legba"
    architecture "x86_64"
    configurations {"Debug", "Release"}

outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

project "Belegium_Matcher"
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++20"
    staticruntime "Off"

    targetdir ("%{wks.location}/bin/" .. outputdir .. "/")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/")

    files {
        "src/**.h",
        "src/**.cpp"
    }

    filter "configurations:Debug"
        symbols "On"

    filter "configurations:Release"
        symbols "Off"
        optimize "Full"