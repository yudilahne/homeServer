<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('team_members', function (Blueprint $table): void {
            $table->id();
            $table->string('name');
            $table->string('role');
            $table->foreignId('focus_project_id')->nullable()->constrained('projects')->nullOnDelete();
            $table->decimal('utilization', 5, 2)->default(0);
            $table->unsignedInteger('active_tasks')->default(0);
            $table->string('status_label')->default('Stabil');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('team_members');
    }
};
