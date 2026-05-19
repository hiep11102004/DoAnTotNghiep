<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\SavingGoal;

class SavingGoalController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $goals = SavingGoal::where('user_id', $request->user()->id)->get();
        return response()->json($goals);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'target_amount' => 'required|numeric',
            'current_amount' => 'nullable|numeric',
            'target_date' => 'nullable|date',
            'color' => 'nullable|string',
        ]);

        $goal = SavingGoal::create(array_merge($validated, [
            'user_id' => $request->user()->id,
            'current_amount' => $validated['current_amount'] ?? 0,
        ]));

        return response()->json($goal, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, string $id)
    {
        $goal = SavingGoal::where('user_id', $request->user()->id)->findOrFail($id);
        return response()->json($goal);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $goal = SavingGoal::where('user_id', $request->user()->id)->findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string',
            'target_amount' => 'required|numeric',
            'current_amount' => 'nullable|numeric',
            'target_date' => 'nullable|date',
            'color' => 'nullable|string',
        ]);

        $goal->update($validated);

        return response()->json($goal);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        $goal = SavingGoal::where('user_id', $request->user()->id)->findOrFail($id);
        $goal->delete();

        return response()->json(null, 204);
    }
}
