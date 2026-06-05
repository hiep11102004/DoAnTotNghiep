<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSavingGoalRequest;
use App\Http\Requests\UpdateSavingGoalRequest;
use App\Http\Resources\SavingGoalResource;
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
        return response()->json(SavingGoalResource::collection($goals));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreSavingGoalRequest $request)
    {
        $validated = $request->validated();

        $goal = SavingGoal::create(array_merge($validated, [
            'user_id'        => $request->user()->id,
            'current_amount' => $validated['current_amount'] ?? 0,
        ]));

        return response()->json(new SavingGoalResource($goal), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, string $id)
    {
        $goal = SavingGoal::where('user_id', $request->user()->id)->findOrFail($id);
        return response()->json(new SavingGoalResource($goal));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateSavingGoalRequest $request, string $id)
    {
        $goal = SavingGoal::where('user_id', $request->user()->id)->findOrFail($id);
        $goal->update($request->validated());

        return response()->json(new SavingGoalResource($goal));
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
