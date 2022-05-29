using DelimitedFiles
using Test

using DataStructures
using Dates
using HTTP
using NCDatasets
using TypedTables

using PlateMotionRequests
_pmr = PlateMotionRequests


function load_mock_response(file)
    open(joinpath(@__DIR__(), "data", file)) do io
        return HTTP.Response(200, read(io))
    end
end


function create_mock_tables()
    ascii_all_models_irregular = Table(;
        lon = [
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            115.270000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            114.450000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
            117.230000,
        ],
        lat = [
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -43.980000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -42.020000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
            -45.560000,
        ],
        velocity_east = [
            36.05,
            36.15,
            37.11,
            35.53,
            37.08,
            36.29,
            35.60,
            35.96,
            35.75,
            35.81,
            37.63,
            36.11,
            34.55,
            36.01,
            35.84,
            34.65,
            34.55,
            36.35,
            37.23,
            37.25,
            38.24,
            36.63,
            38.22,
            37.40,
            36.77,
            37.12,
            36.92,
            36.92,
            38.76,
            37.14,
            35.84,
            37.16,
            36.92,
            35.95,
            35.84,
            37.70,
            34.10,
            34.27,
            35.21,
            33.66,
            35.18,
            34.41,
            33.66,
            34.01,
            33.84,
            33.94,
            35.74,
            34.31,
            32.49,
            34.12,
            33.98,
            32.58,
            32.49,
            34.18,
        ],
        velocity_north = [
            58.21,
            57.73,
            56.91,
            56.99,
            56.87,
            57.43,
            57.78,
            58.51,
            56.31,
            55.97,
            55.68,
            55.91,
            59.07,
            55.54,
            56.78,
            58.84,
            59.07,
            62.20,
            58.04,
            57.55,
            56.72,
            56.81,
            56.69,
            57.25,
            57.62,
            58.34,
            56.15,
            55.80,
            55.50,
            55.71,
            58.95,
            55.37,
            56.60,
            58.73,
            58.95,
            62.08,
            58.56,
            58.14,
            57.31,
            57.38,
            57.27,
            57.84,
            58.13,
            58.88,
            56.65,
            56.35,
            56.09,
            56.35,
            59.31,
            55.89,
            57.19,
            59.08,
            59.31,
            62.46,
        ],
        plate_and_reference = [
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
        ],
        model = [
            "GSRM v2.1",
            "ITRF2014 [2016]",
            "NNR-MORVEL56",
            "GEODVEL 2010",
            "MORVEL 2010",
            "ITRF2008",
            "APKIM2005-DGFI",
            "APKIM2005-IGN",
            "GSRM v1.2",
            "CGPS 2004",
            "REVEL 2000",
            "ITRF2000 (AS&B [2002])",
            "HS3-NUVEL1A",
            "APKIM2000.0",
            "ITRF2000 (D&A [2001])",
            "HS2-NUVEL1A",
            "NUVEL 1A",
            "NUVEL 1",
            "GSRM v2.1",
            "ITRF2014 [2016]",
            "NNR-MORVEL56",
            "GEODVEL 2010",
            "MORVEL 2010",
            "ITRF2008",
            "APKIM2005-DGFI",
            "APKIM2005-IGN",
            "GSRM v1.2",
            "CGPS 2004",
            "REVEL 2000",
            "ITRF2000 (AS&B [2002])",
            "HS3-NUVEL1A",
            "APKIM2000.0",
            "ITRF2000 (D&A [2001])",
            "HS2-NUVEL1A",
            "NUVEL 1A",
            "NUVEL 1",
            "GSRM v2.1",
            "ITRF2014 [2016]",
            "NNR-MORVEL56",
            "GEODVEL 2010",
            "MORVEL 2010",
            "ITRF2008",
            "APKIM2005-DGFI",
            "APKIM2005-IGN",
            "GSRM v1.2",
            "CGPS 2004",
            "REVEL 2000",
            "ITRF2000 (AS&B [2002])",
            "HS3-NUVEL1A",
            "APKIM2000.0",
            "ITRF2000 (D&A [2001])",
            "HS2-NUVEL1A",
            "NUVEL 1A",
            "NUVEL 1",
        ],
    )

    ascii_xyz_gsrm_regular = Table(;
        lon = [
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
        ],
        lat = [
            -35.000000,
            -25.000000,
            -15.000000,
            -5.000000,
            5.000000,
            15.000000,
            25.000000,
            35.000000,
            45.000000,
            -35.000000,
            -25.000000,
            -15.000000,
            -5.000000,
            5.000000,
            15.000000,
            25.000000,
            35.000000,
            45.000000,
        ],
        velocity_x = [
            -50.19,
            -48.08,
            -44.51,
            -21.73,
            -24.68,
            -26.89,
            -28.28,
            -28.82,
            -28.49,
            -47.83,
            -45.47,
            -41.73,
            -19.91,
            -22.86,
            -25.12,
            -26.62,
            -27.32,
            -27.19,
        ],
        velocity_y = [
            16.33,
            7.98,
            -0.60,
            -8.59,
            -8.31,
            -7.78,
            -7.01,
            -6.03,
            -4.87,
            11.27,
            2.39,
            -6.56,
            -12.49,
            -12.21,
            -11.56,
            -10.56,
            -9.24,
            -7.64,
        ],
        velocity_z = [
            46.75,
            51.69,
            55.07,
            -7.32,
            -7.32,
            -7.10,
            -6.66,
            -6.02,
            -5.20,
            48.42,
            53.55,
            57.05,
            -9.88,
            -9.88,
            -9.58,
            -8.99,
            -8.13,
            -7.02,
        ],
        plate_and_reference = [
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
        ],
        model = [
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
        ],
    )

    ascii_gsrm_regular = Table(;
        lon = [
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
        ],
        lat = [
            -35.000000,
            -25.000000,
            -15.000000,
            -5.000000,
            5.000000,
            15.000000,
            25.000000,
            35.000000,
            45.000000,
            -35.000000,
            -25.000000,
            -15.000000,
            -5.000000,
            5.000000,
            15.000000,
            25.000000,
            35.000000,
            45.000000,
        ],
        velocity_east = [
            41.58,
            42.45,
            42.03,
            23.36,
            26.03,
            27.92,
            28.97,
            29.15,
            28.43,
            35.79,
            38.18,
            39.42,
            23.49,
            25.90,
            27.54,
            28.34,
            28.28,
            27.37,
        ],
        velocity_north = [
            56.94,
            56.97,
            56.99,
            -7.34,
            -7.34,
            -7.34,
            -7.34,
            -7.34,
            -7.33,
            58.98,
            59.01,
            59.03,
            -9.92,
            -9.92,
            -9.91,
            -9.91,
            -9.91,
            -9.90,
        ],
        plate_and_reference = [
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
        ],
        model = [
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
        ],
    )

    psvelo_gsrm_regular = Table(;
        lon = [
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            110.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
            120.000000,
        ],
        lat = [
            -35.000000,
            -25.000000,
            -15.000000,
            -5.000000,
            5.000000,
            15.000000,
            25.000000,
            35.000000,
            45.000000,
            -35.000000,
            -25.000000,
            -15.000000,
            -5.000000,
            5.000000,
            15.000000,
            25.000000,
            35.000000,
            45.000000,
        ],
        velocity_east = [
            41.58,
            42.45,
            42.03,
            23.36,
            26.03,
            27.92,
            28.97,
            29.15,
            28.43,
            35.79,
            38.18,
            39.42,
            23.49,
            25.90,
            27.54,
            28.34,
            28.28,
            27.37,
        ],
        velocity_north = [
            56.94,
            56.97,
            56.99,
            -7.34,
            -7.34,
            -7.34,
            -7.34,
            -7.34,
            -7.33,
            58.98,
            59.01,
            59.03,
            -9.92,
            -9.92,
            -9.91,
            -9.91,
            -9.91,
            -9.90,
        ],
        err_east = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        err_north = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        correlation_NE = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        plate_and_reference = [
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "AU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
            "EU(NNR)",
        ],
        model = [
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
            "GSRM v2.1",
        ],
    )

    return ascii_all_models_irregular,
    ascii_gsrm_regular,
    ascii_xyz_gsrm_regular,
    psvelo_gsrm_regular
end


@testset "response parsing" begin
    # Test format validation
    for val in (42, "a", 'a', "ASCII")
        @test_throws _pmr.OptionError _pmr.validate_format(val)
    end
    for val in ("ascii", "ascii_xyz", "psvelo")
        @test _pmr.validate_format(val) == val
    end
    # Test response parsing
    ascii_all_models_irregular,
    ascii_gsrm_regular,
    ascii_xyz_gsrm_regular,
    psvelo_gsrm_regular =
        load_mock_response.((
            "UNAVCO_ASCII_all_models_irregular.dat",
            "UNAVCO_ASCII_GSRMv2_regular.dat",
            "UNAVCO_ASCIIxyz_GSRMv2_regular.dat",
            "UNAVCO_psvelo_GSRMv2_regular.dat",
        ))
    mock_ascii_all_models_irregular,
    mock_ascii_gsrm_regular,
    mock_ascii_xyz_gsrm_regular,
    mock_psvelo_gsrm_regular = create_mock_tables()
    @test _pmr.parse!(ascii_all_models_irregular, "ascii") ==
          mock_ascii_all_models_irregular
    @test _pmr.parse!(ascii_gsrm_regular, "ascii") == mock_ascii_gsrm_regular
    @test _pmr.parse!(ascii_xyz_gsrm_regular, "ascii_xyz") == mock_ascii_xyz_gsrm_regular
    @test _pmr.parse!(psvelo_gsrm_regular, "psvelo") == mock_psvelo_gsrm_regular
end

@testset "I/O" begin
    filename(name) = joinpath(@__DIR__(), name)
    mock_ascii_all_models_irregular,
    mock_ascii_gsrm_regular,
    mock_ascii_xyz_gsrm_regular,
    mock_psvelo_gsrm_regular = create_mock_tables()

    @testset "text files" begin
        try
            write_platemotion(
                filename("ASCII_all_models_irregular.dat"),
                mock_ascii_all_models_irregular,
            )
            @test read_platemotion(filename("ASCII_all_models_irregular.dat")) ==
                  mock_ascii_all_models_irregular
            write_platemotion(filename("ASCII_GSRMv2_regular.dat"), mock_ascii_gsrm_regular)
            @test read_platemotion(filename("ASCII_GSRMv2_regular.dat")) ==
                  mock_ascii_gsrm_regular
            write_platemotion(
                filename("ASCII_XYZ_GSRMv2_regular.dat"),
                mock_ascii_xyz_gsrm_regular,
            )
            @test read_platemotion(filename("ASCII_XYZ_GSRMv2_regular.dat")) ==
                  mock_ascii_xyz_gsrm_regular
            write_platemotion(
                filename("psvelo_GSRMv2_regular.dat"),
                mock_psvelo_gsrm_regular,
            )
            @test read_platemotion(filename("psvelo_GSRMv2_regular.dat")) ==
                  mock_psvelo_gsrm_regular
            writedlm(filename("malformed.dat"), Table(a = [1], b = [1]), '\t')
            @test_throws _pmr.ReadError read_platemotion(filename("malformed.dat"))
            @test_throws _pmr.WriteError write_platemotion(
                filename("tmp.dat"),
                Table(a = [1], b = [1]),
            )
            @test read_platemotion(
                filename("data/parsed_rightaligned_GSRMv2_regular.dat"),
            ) == mock_ascii_gsrm_regular
        finally
            rm(filename("tmp.dat"), force = true)
            rm(filename("ASCII_all_models_irregular.dat"), force = true)
            rm(filename("ASCII_GSRMv2_regular.dat"), force = true)
            rm(filename("ASCII_XYZ_GSRMv2_regular.dat"), force = true)
            rm(filename("psvelo_GSRMv2_regular.dat"), force = true)
            rm(filename("malformed.dat"), force = true)
        end
    end

    @testset "NetCDF" begin
        if Sys.iswindows()
            println("NetCDF writer is currently broken on Windows")
            return
        end
        try
            write_platemotion(filename("ASCII_GSRMv2_regular.nc"), mock_ascii_gsrm_regular)
            ds = NCDataset(filename("ASCII_GSRMv2_regular.nc"))
            # Check global attributes.
            for key in ("Conventions", "title", "institution", "references", "comment")
                haskey(ds, key)
            end
            @test ds.attrib["Conventions"] == "CF-1.9"
            @test ds.attrib["title"] == "Tectonic plate motions"
            @test ds.attrib["institution"] == "https://www.unavco.org/"
            @test ds.attrib["references"] ==
                  "See <https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html#references>"
            @test ds.attrib["comment"] ==
                  "Produced using https://git.sr.ht/~adigitoleo/PlateMotionRequests.jl\n"
            # Check dimensions.
            @test haskey(ds.dim, "lat")
            @test haskey(ds.dim, "lon")
            @test ds["lat"][:] == collect(-35:10:45)
            @test ds["lon"][:] == [110, 120]
            # Check variables.
            for key in ("velocity_east", "velocity_north", "plate_and_reference", "model")
                @test haskey(ds, key)
            end
            @test ds["velocity_east"][:] == [
                41.58 35.79
                42.45 38.18
                42.03 39.42
                23.36 23.49
                26.03 25.90
                27.92 27.54
                28.97 28.34
                29.15 28.28
                28.43 27.37
            ]
            @test ds["velocity_north"][:] == [
                56.94 58.98
                56.97 59.01
                56.99 59.03
                -7.34 -9.92
                -7.34 -9.92
                -7.34 -9.91
                -7.34 -9.91
                -7.34 -9.91
                -7.33 -9.90
            ]
            @test all(x -> x == "GSRM v2.1", ds["model"][:])
            @test ds["plate_and_reference"] == [
                "AU(NNR)" "AU(NNR)"
                "AU(NNR)" "AU(NNR)"
                "AU(NNR)" "AU(NNR)"
                "EU(NNR)" "EU(NNR)"
                "EU(NNR)" "EU(NNR)"
                "EU(NNR)" "EU(NNR)"
                "EU(NNR)" "EU(NNR)"
                "EU(NNR)" "EU(NNR)"
                "EU(NNR)" "EU(NNR)"
            ]
            @test_throws _pmr.WriteError write_platemotion(
                filename("ASCII_all_models_irregular.nc"),
                mock_ascii_all_models_irregular,
            )
        finally
            rm(filename("ASCII_GSRMv2_regular.nc"), force = true)
            rm(filename("ASCII_all_models_irregular.nc"), force = true)
        end
    end
end
