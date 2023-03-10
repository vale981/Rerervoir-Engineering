"""
This is a loose collection to naively calculate the time evolution
operator and Floquet Hamiltonian for a given time dependent
Hamiltonian `H(t)`.
"""
module FloquetUtils

import LinearAlgebra: I, eigvecs, eigen, Diagonal
import DifferentialEquations as de

export time_evolution_op
export floquet_hamiltonian
export KickOperator

using ..Utilities

"""
    time_evolution_op(H, T, args...; kwargs...)

Calculate the time evolution operator for a Hamiltonian `H` up to a
total time `T`. The rest arguments are passed on to
[`de.solve`](@ref).
"""
function time_evolution_op(H::Function, T::Real, args...; kwargs...)
    function u_step!(dU, U, _, t)
        dU .= -1im * H(t) * U
    end

    N = size(H(0), 1)
    u0 = Matrix{ComplexF64}(I, N, N)

    tspan = (0.0, T)
    prob = de.ODEProblem(u_step!, u0, tspan)
    de.solve(prob, args...; kwargs...)
end


"""
    floquet_hamiltonian(U::Matrix, T)

Returns the Floquet Hamiltonian given a unitary matrix `U` and a time
`T`.
"""
function floquet_hamiltonian(U::Matrix, T::Real)
    1im / T * log(U)
end



"""
    floquet_hamiltonian(H::Function, T)

Returns the Floquet Hamiltonian given a Hamiltionian `H` and a time
`T`. The rest arguments are passed on to
[`de.solve`](@ref).
"""
function floquet_hamiltonian(H::Function, T::Real, args...; kwargs...)
    U = time_evolution_op(H, T, args...; kwargs...)
    floquet_hamiltonian(U(T), T)
end

"""
    trivial_floquet_hamiltonian(H, T, restrict_energies=false)

Returns the Floquet Hamiltonian for a Hamiltonain `H` that commutes
with itself at different times.
"""
function trivial_floquet_hamiltonian(H::Function, T::Real, restrict_energies::Bool=false)
    function h_step!(dU, _, _, t)
        dU .= H(t)
    end

    dimension = size(H(0), 1)
    u0 = zeros(ComplexF64, dimension, dimension)
    prob = de.ODEProblem(h_step!, u0, (0.0, T))

    integrated_hamiltonian = de.solve(prob)

    H_F = integrated_hamiltonian(T) / T

    if restrict_energies
        energies, vecs = eigen(H_F)
        energies .= restrict_to_range.(energies, π / T)
        H_F .= vecs * Diagonal(energies) * vecs'
    end

    H_F
end


struct KickOperator
    U
    H_F::Matrix


    @doc """
        KickOperator(U(t), H_F::Matrix)

    Return the Kick operator Given the time evolution operator `U(t)` and the Floquet Hamiltonian
    `H_F`.
    """
    function KickOperator(U, H_F::Matrix)
        if size(U(0)) != size(H_F)
            throw(DimensionMismatch("`U` and `H_F` should have the same dimension."))
        end
        new(U, H_F)
    end
end

"""
    KickOperator(H(t), T)

Return the Kick operator Given the Hamiltonian `H(t)` and the total time ``T``.
"""
function KickOperator(H::Function, T::Real)
    U = time_evolution_op(H, T)
    H_F = floquet_hamiltonian(U(T), T)
    KickOperator(U, H_F)
end

"""
    K(t)

Return the Kick operator at time t.
"""
function (K::KickOperator)(t::Real)
    K.U(t) * exp(1im * K.H_F * t)
end



end
